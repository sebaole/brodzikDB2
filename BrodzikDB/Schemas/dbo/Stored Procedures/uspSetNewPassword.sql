CREATE PROCEDURE [dbo].[uspSetNewPassword]
(
	 @LoginName				NCHAR(9)
	,@PasswordHash			NVARCHAR(128)
	,@PasswordSalt			NVARCHAR(128)
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
			UPDATE dbo.tblUser
			SET
				PasswordHash = @PasswordHash
				,PasswordSalt = @PasswordSalt
			WHERE LoginName = @LoginName

			IF @@ROWCOUNT = 0
			BEGIN
				RAISERROR('Invalid LoginName' ,16 ,1)
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