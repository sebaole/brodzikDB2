CREATE PROCEDURE [dbo].[uspGetSalt]
(
	 @LoginName			NCHAR(9) 
	,@PasswordSalt		NVARCHAR(128) OUTPUT
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
			SET @PasswordSalt = (
								SELECT PasswordSalt 
								FROM dbo.tblUser 
								WHERE LoginName = @LoginName
								)

			IF @PasswordSalt IS NULL
			BEGIN
				RAISERROR('Nieprawidłowy Login', 16, 1)
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