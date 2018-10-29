CREATE PROCEDURE [dbo].[uspAddShoppingCartItem]
(
	 @LoginName			NCHAR(9)
	,@ProductID			INT
	,@Quantity			TINYINT
	,@DeliveryDate		DATETIME
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0
		,@UserID		INT
		,@ProductName	NVARCHAR(128)
		,@DeliveryDay	TINYINT

	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)

	BEGIN TRY

		/* some extra validations here */

		--check if IsActive
		SET @ProductName = (SELECT ProductName FROM dbo.tblProduct WHERE ProductID = @ProductID AND IsActive = 1)
		IF @ProductName IS NULL
		BEGIN
			RAISERROR ('Sorry, product %s is no longer available.', 16, 1, @ProductName)
		END

		IF TRY_CAST(@DeliveryDate AS DATE) IS NULL
			BEGIN
				RAISERROR ('Something wrong with delivery date.', 16, 1)
			END

		-- check delivery date, min. 2 days after today
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
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsMonday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		ELSE IF @DeliveryDay = 2
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsTuesday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		ELSE IF @DeliveryDay = 3
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsWednesday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		ELSE IF @DeliveryDay = 4
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsThursday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		ELSE IF @DeliveryDay = 5
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsFriday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		ELSE IF @DeliveryDay = 6
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsSaturday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		ELSE IF @DeliveryDay = 7
			BEGIN
				IF EXISTS (SELECT 1 FROM dbo.tblProduct P WHERE P.ProductID = @ProductID AND P.IsSunday = 0)
					BEGIN
						RAISERROR ('The product you are trying to add to the cart is not available for the delivery date you have selected.', 16, 1)
					END
			END
		/******************************************************************************************/
		-- end products days availability validation
		/******************************************************************************************/

		BEGIN TRAN
					
			/* target sql statements here */
			IF EXISTS (	SELECT 1 
						FROM dbo.tblShoppingCart 
						WHERE 
							UserID = @UserID
							AND ProductID = @ProductID
							AND DeliveryDate = @DeliveryDate
							AND DateExpired >= GETDATE()
						)
				BEGIN
					IF @Quantity = 0
						BEGIN
							DELETE FROM dbo.tblShoppingCart
							WHERE 	
								UserID = @UserID
								AND ProductID = @ProductID
								AND DeliveryDate = @DeliveryDate 
								AND DateExpired >= GETDATE()
						END
					ELSE
						BEGIN
							UPDATE dbo.tblShoppingCart
							SET	Quantity = @Quantity
							WHERE 	
								UserID = @UserID
								AND ProductID = @ProductID
								AND DeliveryDate = @DeliveryDate
								AND DateExpired >= GETDATE()
						END
				END
			ELSE
				BEGIN
					INSERT INTO dbo.tblShoppingCart
					(
						 UserID
						,ProductID
						,Quantity
						,DateExpired
						,DeliveryDate
					)
					VALUES
					(
						 @UserID
						,@ProductID
						,@Quantity
						,DATEADD(SECOND, -1,CAST(DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) AS DATETIME)) -- end of day
						,@DeliveryDate
					)
				END

		COMMIT

	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		;THROW

	END CATCH

RETURN @ReturnValue

END
