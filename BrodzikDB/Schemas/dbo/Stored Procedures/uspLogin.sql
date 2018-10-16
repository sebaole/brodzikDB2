CREATE PROCEDURE [dbo].[uspLogin]
(
	 @LoginName				NCHAR(9)
	,@Password				NVARCHAR(128)
	--,@ResponseMsg			NVARCHAR(256) = '' OUTPUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		IF NOT EXISTS (SELECT 1 FROM [dbo].[tblUser] WHERE LoginName = @LoginName)
			BEGIN
				RAISERROR ('Invalid LoginName', 16, 1)
			END
		
		IF EXISTS (SELECT UserID FROM [dbo].[tblUser] WHERE LoginName = @LoginName AND PasswordHash = HASHBYTES('SHA2_512', @Password + CAST(PasswordSalt AS NVARCHAR(36))))
			BEGIN
				RAISERROR ('Incorrect Password', 16, 1)
			END
		--ELSE
		--		SET @ResponseMsg = 'User successfully logged in'
		
	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		DECLARE
			@ErrorMessage NVARCHAR(4000)
			,@ErrorSeverity INT
			,@ErrorState INT

		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH

RETURN @ReturnValue

END