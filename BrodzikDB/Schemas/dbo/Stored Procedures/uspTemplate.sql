CREATE PROCEDURE [dbo].[uspTemplate]
(
	 @InputParam1	NVARCHAR(64) 
	,@InputParam2	BIT
	,@OutputParam	INT OUTPUT
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
			SET @OutputParam = 1
		
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