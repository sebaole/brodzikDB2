CREATE PROCEDURE [dbo].[uspGetShoppingCartItemsCount]
(
	  @LoginName			NCHAR(9)
	 ,@ItemsInCartCount		INT OUT
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
			SET @ItemsInCartCount = (
					SELECT COUNT(*)
					FROM dbo.tblShoppingCart
					WHERE	
						UserID = @UserID
						AND DateExpired >= GETDATE()
					)

		COMMIT

	END TRY
	BEGIN CATCH
		
		SET @ItemsInCartCount = NULL
		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		;THROW

	END CATCH

RETURN @ReturnValue

END
