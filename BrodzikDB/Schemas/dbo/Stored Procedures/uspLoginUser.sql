CREATE PROCEDURE [dbo].[uspLoginUser] 
(
	 @login			NVARCHAR(9)
	,@pass_hash		NVARCHAR(500)
	,@ses_id		NVARCHAR(200)
	,@session_time	INT
)	
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue		SMALLINT = 0
		,@max_bad_pass		INT = 5
		,@saved_pass_hash	NVARCHAR(500)
		,@isActive			BIT
		,@return_status		NVARCHAR(100)

	SET @saved_pass_hash = (SELECT PasswordHash FROM dbo.tblUser WHERE LoginName = @login)
	SET @isActive = (SELECT IsActive FROM dbo.tblUser WHERE LoginName = @login)

	BEGIN TRY
		
		BEGIN TRAN
					
			IF @pass_hash = @saved_pass_hash AND @isActive = 1
				BEGIN
					/* Weryfikacja czy sesja juz istnieje */					
					EXEC dbo.uspCheckSession
						 @ses_id = @ses_id
						,@session_time = @session_time
						,@status = @return_status OUTPUT
								
					IF @return_status = 'exist' 
						BEGIN
						SELECT 'exist' as answer
					
						EXEC log.uspAddAppEventLog 
							@EventMessage = 'Login success (session exists)'
							,@LoginName = @login

						END
					ELSE
						BEGIN
							INSERT INTO [dbo].[tblSessions] 
							(
								ID_SES		
								,Login		
								,DateStart	
								,LastUpdate	
								,Active
							)
							VALUES 
							(
								 @ses_id
								,@login
								,GETDATE()
								,GETDATE()
								,1
							)

							SELECT 'ok' as answer

							EXEC log.uspAddAppEventLog 
								@EventMessage = 'Login success'
								,@LoginName = @login
						END							
				END			
			ELSE
				BEGIN 					
					IF @isActive = 0 
						BEGIN
							EXEC log.uspAddAppEventLog 
								@EventMessage = 'Login error'
								,@ErrorMessage = 'Inactive account'
								,@LoginName = @login
						END
					ELSE
						BEGIN
							EXEC log.uspAddAppEventLog 
								@EventMessage = 'Login error'
								,@ErrorMessage = 'Incorrect password or login does not exist'
								,@LoginName = @login
						END
						
					SELECT 'not' as answer
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