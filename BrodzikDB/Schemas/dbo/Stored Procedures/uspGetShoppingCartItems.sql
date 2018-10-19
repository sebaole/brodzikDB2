CREATE PROCEDURE [dbo].[uspGetShoppingCartItems]
(
	 @UserID	INT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		
		BEGIN TRAN
					
			/* target sql statements here */
			SELECT
				 ProductID
				,Quantity
			FROM dbo.tblShoppingCart
			WHERE	
				UserID = @UserID
				AND DateExpired >= GETDATE()
		
		COMMIT

	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		DECLARE
			 @ErrorMessage	NVARCHAR(4000)
			,@ErrorSeverity	INT
			,@ErrorState	INT

		SET @ErrorMessage	= ERROR_MESSAGE()
		SET @ErrorSeverity	= ERROR_SEVERITY()
		SET @ErrorState		= ERROR_STATE()

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH

RETURN @ReturnValue

END
