﻿CREATE PROCEDURE [dbo].[uspAddOrder]
(	
	 @LoginName					NCHAR(9)
	,@DeliveryDate				DATETIME
	,@IsSelfPickup				BIT
	,@CustomerNote				NVARCHAR(256) = NULL
	,@DeliveryCity				NVARCHAR(64) = NULL
	,@DeliveryState				NVARCHAR(64) = NULL
	,@DeliveryZipCode			NVARCHAR(6) = NULL
	,@DeliveryStreet			NVARCHAR(128) = NULL
	,@DeliveryNumberLine1		NVARCHAR(16) = NULL
	,@DeliveryNumberLine2		NVARCHAR(16) = NULL	
	,@IsRecurring				BIT = 0
	,@RecurrenceWeekNumber		TINYINT = NULL
	,@DateEndRecurrence			DATETIME = NULL
	,@RecurrenceBaseOrderID		INT = NULL
	,@OrderID					INT OUT
	,@OrderNr					NVARCHAR(16) OUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue				SMALLINT = 0
		,@OrderCount				INT = 0
		,@UserID					INT
		,@DeliveryDay				TINYINT
		,@ContactPersonFirstName	NVARCHAR(150)
		,@ContactPersonLastName		NVARCHAR(150)
		,@ContactPhoneNumber		NVARCHAR(32)

	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)

	BEGIN TRY

		SET @OrderCount =	(
							SELECT COUNT(*) 
							FROM dbo.tblOrder WITH(NOLOCK)
							WHERE 
								OrderDate >= CAST(GETDATE() AS DATE) 
								AND OrderDate < CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
							)

		SET @OrderNr = (SELECT CONCAT(YEAR(GETDATE()), FORMAT(MONTH(GETDATE()), '00'), FORMAT(DAY(GETDATE()), '00'), '_', FORMAT(@OrderCount + 1, '0000') ))

		/* some extra validations here */


		/******************************************************************************************/
		-- validation only for orders created by user
		/******************************************************************************************/
		IF @RecurrenceBaseOrderID IS NULL	
			BEGIN
				/******************************************************************************************/
				-- check if shopping cart is not empty
				/******************************************************************************************/
				IF NOT EXISTS (	SELECT 1 
								FROM dbo.tblShoppingCart 
								WHERE 
									UserID = @UserID
									AND DeliveryDate = @DeliveryDate
									AND DateExpired >= GETDATE()
								)
					BEGIN
						--RAISERROR ('ShoppingCart on the selected delivery date has expired. There is no item(s) inside.', 16, 1)
						RAISERROR ('Upłynął termin ważności koszyka dla wybranej daty dostawy. Koszyk jest pusty', 16, 1)
					END
			END
		
		/******************************************************************************************/
		-- check consistency for recurring order
		/******************************************************************************************/
		IF @IsRecurring = 1 AND (@RecurrenceWeekNumber IS NULL OR @DateEndRecurrence IS NULL)
			BEGIN
				RAISERROR('Niewystarczająca liczba parametrów dla zamówienia cyklicznego', 16, 1)
			END

		IF @RecurrenceBaseOrderID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.tblOrder WHERE OrderID = @RecurrenceBaseOrderID AND IsRecurring = 1)
			BEGIN
				RAISERROR('OrderID %i nie istnieje lub nie jest to zamówienie cykliczne', 16, 1, @RecurrenceBaseOrderID)
			END

		/******************************************************************************************/
		-- check address params are provided when IsSelfPickup = 0
		/******************************************************************************************/
		IF @IsSelfPickup = 0 
			AND (
					@DeliveryCity IS NULL		
					OR @DeliveryState IS NULL		
					OR @DeliveryZipCode IS NULL	
					OR @DeliveryStreet IS NULL	
					OR @DeliveryNumberLine1 IS NULL
					OR @DeliveryNumberLine2 IS NULL
				)
			BEGIN
				RAISERROR ('Niewystarczająca liczba parametrów dotyczących adresu dla opcji DOSTAWA', 16, 1)
			END

		IF @IsSelfPickup = 0
			BEGIN
				/* workaround to store historical contact person details */
				SELECT TOP 1
					@ContactPersonFirstName = ContactPersonFirstName
					,@ContactPersonLastName = ContactPersonLastName
					,@ContactPhoneNumber = ContactPhoneNumber
				FROM dbo.tblAddress
				WHERE 
					UserID = @UserID
					AND City = @DeliveryCity
					AND ZipCode = @DeliveryZipCode
					AND Street = @DeliveryStreet
					AND NumberLine1 = @DeliveryNumberLine1
			END
		
		/******************************************************************************************/
		-- check date
		/******************************************************************************************/
		IF TRY_CAST(@DeliveryDate AS DATE) IS NULL
			BEGIN
				RAISERROR ('Coś nie tak z datą dostawy', 16, 1)
			END

		/******************************************************************************************/
		-- check delivery date, min. 2 days after today
		/******************************************************************************************/
		IF CAST(@DeliveryDate AS DATE) < DATEADD(DAY, 2, CAST(GETDATE() AS DATE))
			BEGIN
				RAISERROR ('Data dostawy nie może być mniejsza niż dziś +2 dni', 16, 1)
			END

		/******************************************************************************************/
		-- check products days availability
		/******************************************************************************************/
		SET DATEFIRST  1;
		SET @DeliveryDay = (SELECT DATEPART(WEEKDAY, @DeliveryDate))
		
		IF @RecurrenceBaseOrderID IS NULL /* for orders run by user based on shopping cart */
			BEGIN
				IF @DeliveryDay = 1
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID							
										AND P.IsMonday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
				ELSE IF @DeliveryDay = 2
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID
										AND P.IsTuesday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
				ELSE IF @DeliveryDay = 3
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID
										AND P.IsWednesday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
				ELSE IF @DeliveryDay = 4
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID
										AND P.IsThursday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
				ELSE IF @DeliveryDay = 5
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID
										AND P.IsFriday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
				ELSE IF @DeliveryDay = 6
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID
										AND P.IsSaturday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
				ELSE IF @DeliveryDay = 7
					BEGIN
						IF EXISTS (SELECT 1
									FROM dbo.tblShoppingCart SC
									INNER JOIN dbo.tblProduct P
										ON SC.ProductID = P.ProductID
										AND P.IsSunday = 0
									WHERE 
										SC.UserID = @UserID
										AND SC.DateExpired >= GETDATE()
										AND SC.DeliveryDate = @DeliveryDate
									)
									BEGIN
										RAISERROR ('Jeden z twoich produktów nie jest już dostępny na wskazany dzień dostawy', 16, 1)
									END
					END
			END
		/******************************************************************************************/
		-- end products days availability validation
		/******************************************************************************************/

		BEGIN TRAN
					
			/* target sql statements here */
			
			/******************************************************************************************/
			/* populate tblOrder and get OrderID */ 
			/******************************************************************************************/
			INSERT INTO dbo.tblOrder
			(
				 [UserID]                 
				,[OrderNr]                             
				,[DeliveryDate]           
				,[IsSelfPickup]           
				,[CustomerNote]                      
				,[DeliveryCity]           
				,[DeliveryState]          
				,[DeliveryZipCode]        
				,[DeliveryStreet]         
				,[DeliveryNumberLine1]    
				,[DeliveryNumberLine2] 			
				,[IsRecurring]			
				,[RecurrenceWeekNumber]		
				,[DateEndRecurrence]
				,[RecurrenceBaseOrderID]
				,[ContactPersonFirstName]
				,[ContactPersonLastName]
				,[ContactPhoneNumber]
			)
			VALUES
			(
				@UserID
				,@OrderNr
				,@DeliveryDate
				,@IsSelfPickup
				,@CustomerNote
				,@DeliveryCity
				,@DeliveryState
				,@DeliveryZipCode
				,@DeliveryStreet
				,@DeliveryNumberLine1
				,@DeliveryNumberLine2
				,@IsRecurring			
				,@RecurrenceWeekNumber	
				,@DateEndRecurrence		
				,@RecurrenceBaseOrderID
				,@ContactPersonFirstName
				,@ContactPersonLastName
				,@ContactPhoneNumber
			)

			SET @OrderID = SCOPE_IDENTITY()


			/******************************************************************************************/
			/* populate tblOrderItem from tblShoppingCart (for orders created by user) or from query (for reccuring orders) */ 
			/******************************************************************************************/

			IF OBJECT_ID('tempdb..#tempShoppingCart') IS NOT NULL DROP TABLE #tempShoppingCart
			CREATE TABLE #tempShoppingCart
			(
				ShoppingCartID	INT NULL
				,UserID			INT NOT NULL
				,ProductID		INT NOT NULL
				,Quantity		INT NOT NULL
				,IsAvailable	BIT NOT NULL
			)
			
			IF @RecurrenceBaseOrderID IS NULL /* for orders run by user based on shopping cart */
				BEGIN
					INSERT INTO #tempShoppingCart
					(
						ShoppingCartID
						,UserID	
						,ProductID		
						,Quantity
						,IsAvailable
					)	
					SELECT
						ShoppingCartID
						,UserID
						,ProductID
						,Quantity
						,[IsAvailable] = 1
					FROM dbo.tblShoppingCart
					WHERE 
						UserID = @UserID
						AND DeliveryDate = @DeliveryDate
						AND DateExpired >= GETDATE()
				END
			ELSE							/* for recurring orders run by automated scripts based on existing order */
				BEGIN
					INSERT INTO #tempShoppingCart
					(
						ShoppingCartID
						,UserID	
						,ProductID		
						,Quantity
						,IsAvailable
					)	
					SELECT
						ShoppingCartID = NULL
						,UserID = O.UserID
						,ProductID = OI.ProductID
						,Quantity = OI.Quantity
						/* additional check for recurring orders created not from shopping cart */
						,[IsAvailable] =CASE 
											WHEN @DeliveryDay = 1 AND P.IsMonday = 0 THEN 0
											WHEN @DeliveryDay = 2 AND P.IsTuesday = 0 THEN 0
											WHEN @DeliveryDay = 3 AND P.IsWednesday = 0 THEN 0
											WHEN @DeliveryDay = 4 AND P.IsThursday = 0 THEN 0
											WHEN @DeliveryDay = 5 AND P.IsFriday = 0 THEN 0
											WHEN @DeliveryDay = 6 AND P.IsSaturday = 0 THEN 0
											WHEN @DeliveryDay = 7 AND P.IsSunday = 0 THEN 0
											ELSE 1
										END
					FROM dbo.tblOrder O
					INNER JOIN dbo.tblOrderItem OI
						ON O.OrderID = OI.OrderID				
					INNER JOIN dbo.tblProduct P
						ON OI.ProductID = P.ProductID		
					WHERE O.OrderID = @RecurrenceBaseOrderID
				END


			INSERT INTO dbo.tblOrderItem
			(
				 [OrderID]             
				,[ProductID]           
				,[ProductName]         
				,[Quantity]  
				,[UnitPrice]
				,[VATRate]  
				,GrossPriceWithDiscount
			)
			SELECT
				@OrderID
				,SC.ProductID
				,P.ProductName
				,SC.Quantity
				,[UnitPrice] = IIF(U.IsWholesalePriceActive = 0, P.UnitRetailPrice, P.UnitWholesalePrice)
				,V.VATRate
				,[GrossPriceWithDiscount] = IIF(U.IsKDR = 1 AND PC.IsKDRActive = 1
												, ROUND(IIF(U.IsWholesalePriceActive = 0, P.UnitRetailPrice, P.UnitWholesalePrice) * (1 + V.VATRate), 2) - PC.KDRGrossDiscount
												, ROUND(IIF(U.IsWholesalePriceActive = 0, P.UnitRetailPrice, P.UnitWholesalePrice) * (1 + V.VATRate), 2)
												)
			FROM #tempShoppingCart SC
			INNER JOIN dbo.tblProduct P
				ON SC.ProductID = P.ProductID
			INNER JOIN dict.tblProductCategory PC
				ON P.CategoryID = PC.CategoryID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			INNER JOIN dbo.tblUser U
				ON SC.UserID = U.UserID
			WHERE SC.IsAvailable = 1

			/******************************************************************************************/
			/* delete item(s) from tblShoppingCart */
			/******************************************************************************************/
			IF @RecurrenceBaseOrderID IS NULL
				BEGIN
					DELETE SC
					FROM dbo.tblShoppingCart SC
					INNER JOIN #tempShoppingCart tSC
					ON SC.ShoppingCartID = tSC.ShoppingCartID
				END


			/******************************************************************************************/
			/* populate tblOrderHistory */ 
			/******************************************************************************************/
			EXEC [dbo].[uspAddOrderHistoryStatus] @OrderID = @OrderID, @StatusCode = 'NEW'


		COMMIT

	END TRY
	BEGIN CATCH

		SET @OrderID = NULL       
		SET @OrderNr = NULL       
		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		;THROW

	END CATCH

RETURN @ReturnValue

END