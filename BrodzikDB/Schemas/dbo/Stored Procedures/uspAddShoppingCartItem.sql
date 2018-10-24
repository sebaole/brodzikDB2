CREATE PROCEDURE [dbo].[uspAddShoppingCartItem]
(
	 @LoginName			NCHAR(9)
	,@ProductID			INT
	,@Quantity			TINYINT
	--> price should be getting from target table at the moment product is added to the shopping cart and store in this table???
	
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0
		,@UserID		INT

	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)

	BEGIN TRY

		/* some extra validations here */
		
		BEGIN TRAN
					
			/* target sql statements here */
			IF EXISTS (	SELECT 1 
						FROM dbo.tblShoppingCart 
						WHERE 
							UserID = @UserID
							AND ProductID = @ProductID
							AND DateExpired >= GETDATE()
						)
				BEGIN
					IF @Quantity = 0
						BEGIN
							DELETE FROM dbo.tblShoppingCart
							WHERE 	
								UserID = @UserID
								AND ProductID = @ProductID
								AND DateExpired >= GETDATE()
						END
					ELSE
						BEGIN
							UPDATE dbo.tblShoppingCart
							SET	Quantity = @Quantity
							WHERE 	
								UserID = @UserID
								AND ProductID = @ProductID
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
					)
					VALUES
					(
						 @UserID
						,@ProductID
						,@Quantity
						,DATEADD(SECOND, -1,CAST(DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) AS DATETIME)) -- end of day
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
