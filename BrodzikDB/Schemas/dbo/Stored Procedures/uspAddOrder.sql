CREATE PROCEDURE [dbo].[uspAddOrder]
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
	,@TotalPrice				MONEY
	,@TotalPriceWithDiscount	MONEY
	
	,@IsRecurring				BIT = NULL
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
		@ReturnValue	SMALLINT = 0
		,@OrderCount	INT = 0
		,@UserID		INT
		,@DeliveryDay	TINYINT

	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)

	BEGIN TRY

		SET @OrderCount =	(
							SELECT COUNT(*) 
							FROM dbo.tblOrder WITH(NOLOCK)
							WHERE 
								OrderDate >= CAST(GETDATE() AS DATE) 
								AND OrderDate < CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
							)

		SET @OrderNr = (SELECT CONCAT(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), '_', FORMAT(@OrderCount + 1, '0000') ))

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
						RAISERROR ('ShoppingCart on the selected delivery date has expired. There is no item(s) inside.', 16, 1)
					END
			END
		
		/******************************************************************************************/
		-- check consistency for recurring order
		/******************************************************************************************/
		IF @IsRecurring = 1 AND (@RecurrenceWeekNumber IS NULL OR @DateEndRecurrence IS NULL)
			BEGIN
				RAISERROR('Insufficient number of parameters for recurring orders.', 16, 1)
			END

		IF NOT EXISTS (SELECT 1 FROM dbo.tblOrder WHERE OrderID = @RecurrenceBaseOrderID AND IsRecurring = 1)
			BEGIN
				RAISERROR('OrderID %i does not exist or it is not recurring order.', 16, 1, @RecurrenceBaseOrderID)
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
				RAISERROR ('Not all address data has been entered.', 16, 1)
			END
		
		/******************************************************************************************/
		-- check date
		/******************************************************************************************/
		IF TRY_CAST(@DeliveryDate AS DATE) IS NULL
			BEGIN
				RAISERROR ('Something wrong with delivery date.', 16, 1)
			END

		/******************************************************************************************/
		-- check delivery date, min. 2 days after today
		/******************************************************************************************/
		IF CAST(@DeliveryDate AS DATE) < DATEADD(DAY, 2, CAST(GETDATE() AS DATE))
			BEGIN
				RAISERROR ('Delivery date must be at least 2 day(s) after today.', 16, 1)
			END

		/******************************************************************************************/
		-- check products days availability
		/******************************************************************************************/
		SET DATEFIRST  1;
		SET @DeliveryDay = (SELECT DATEPART(WEEKDAY, @DeliveryDate))

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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
								RAISERROR ('One of your product is not available for the delivery date you have selected.', 16, 1)
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
				,[TotalPrice]             
				,[TotalPriceWithDiscount] 
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
			)
			VALUES
			(
				@UserID
				,@OrderNr
				,@DeliveryDate
				,@IsSelfPickup
				,@TotalPrice 
				,@TotalPriceWithDiscount
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
			)
			
			IF @RecurrenceBaseOrderID IS NULL /* for orders run by user based on shopping cart */
				BEGIN
					INSERT INTO #tempShoppingCart
					(
						ShoppingCartID
						,UserID	
						,ProductID		
						,Quantity
					)	
					SELECT
						ShoppingCartID
						,UserID
						,ProductID
						,Quantity
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
					)	
					SELECT
						ShoppingCartID = NULL
						,UserID = O.UserID
						,ProductID = OI.ProductID
						,Quantity = OI.Quantity
					FROM dbo.tblOrder O
					INNER JOIN dbo.tblOrderItem OI
						ON O.OrderID = OI.OrderID
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