CREATE PROCEDURE [dbo].[uspAddOrder]
(	
	 @UserID                INT	
	,@DeliveryDate          DATETIME
	,@IsSelfPickup          BIT
	,@CustomerNote          NVARCHAR(256) = NULL
	,@DeliveryCity          NVARCHAR(64) = NULL
	,@DeliveryState         NVARCHAR(64) = NULL
	,@DeliveryZipCode       NVARCHAR(6) = NULL
	,@DeliveryStreet        NVARCHAR(128) = NULL
	,@DeliveryNumberLine1   NVARCHAR(16) = NULL
	,@DeliveryNumberLine2   NVARCHAR(16) = NULL

	,@OrderID               INT OUT
	,@OrderNr               NVARCHAR(16) OUT -- it should be the only return value ?
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0
		,@OrderCount	INT = 0

	BEGIN TRY

		SET @OrderCount =	(
							SELECT COUNT(*) 
							FROM dbo.tblOrder WITH(NOLOCK)
							WHERE 
								OrderDate >= CAST(GETDATE() AS DATE) 
								AND OrderDate < DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) 
							)

		SET @OrderNr = (SELECT CONCAT(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), '_', FORMAT(@OrderCount + 1, '000') ))

		/* some extra validations here */

		-- check if shopping cart is not empty
		IF NOT EXISTS (	SELECT 1 
						FROM dbo.tblShoppingCart 
						WHERE 
							UserID = @UserID
							AND DateExpired >= GETDATE()
						)
			BEGIN
				RAISERROR ('ShoppingCart has expired. There is no item(s) inside.', 16, 1)
			END

		-- check availability (days) vs DeliveryDate ?

		
		BEGIN TRAN
					
			/* target sql statements here */
			
			/* populate tblOrder and get OrderID */ 
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
			)
			VALUES
			(
				@UserID
				,@OrderNr
				,@DeliveryDate
				,@IsSelfPickup
				,0 -- to consider should it be passing by params or getting from db? 
				,0 -- to consider should it be passing by params or getting from db? 
				,@CustomerNote
				,@DeliveryCity
				,@DeliveryState
				,@DeliveryZipCode
				,@DeliveryStreet
				,@DeliveryNumberLine1
				,@DeliveryNumberLine2
			)

			SET @OrderID = SCOPE_IDENTITY()

			/* populate tblOrderItem from tblShoppingCart */ 
			;WITH CTE_ShoppingCart AS
			(
				SELECT
					UserID
					,ProductID
					,Quantity
				FROM dbo.tblShoppingCart
				WHERE 
					UserID = @UserID
					AND DateExpired >= GETDATE()
			)

			INSERT INTO dbo.tblOrderItem
			(
				 [OrderID]             
				,[ProductID]           
				,[ProductName]         
				,[Quantity]            
				,[UnitPrice]           
				,[VATRate]             
				,[UserDiscountRate]    
				,[ProductDiscountRate] 
			)
			SELECT
				@OrderID
				,SC.ProductID
				,P.ProductName
				,SC.Quantity
				,[UnitPrice] = IIF(U.IsBusinessClient = 0, P.UnitRetailPrice, P.UnitWholesalePrice)
				,V.VATRate
				,NULL
				,NULL
			FROM CTE_ShoppingCart SC
			INNER JOIN dbo.tblProduct P
				ON SC.ProductID = P.ProductID
			INNER JOIN dict.tblVATRate V
				ON P.VATID = V.VATID
			INNER JOIN dbo.tblUser U
				ON SC.UserID = U.UserID

			IF @@ROWCOUNT = 0
			BEGIN
				RAISERROR('ShoppingCart has expired. There is no item(s) inside.' ,16 ,1)
			END

			/* delete item(s) from tblShoppingCart */ 
			DELETE FROM CTE_ShoppingCart

			/* populate tblOrderHistory */ 
			EXEC [dbo].[uspAddOrderHistoryStatus] @OrderID = @OrderID, @StatusCode = 'START'


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