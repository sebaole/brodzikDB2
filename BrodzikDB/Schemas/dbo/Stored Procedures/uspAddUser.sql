﻿CREATE PROCEDURE [dbo].[uspAddUser]
(
	 @UserRoleName			NVARCHAR(16) 
	,@LoginName				NCHAR(9)
	,@PasswordHash			NVARCHAR(128)
	,@PasswordSalt			NVARCHAR(128)
	,@PhoneNumber			NCHAR(9)
	,@Email					NVARCHAR(256) = NULL
	,@FirstName				NVARCHAR(150) = NULL
	,@LastName				NVARCHAR(150) = NULL
	,@IsBusinessClient		BIT
	,@CompanyName			NVARCHAR(256) = NULL
	,@NIP					NCHAR(10) = NULL
	,@IsDeliveryActive		BIT = NULL
	,@UserID				INT OUTPUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@UserRoleID		TINYINT
		,@ReturnValue	SMALLINT = 0

	BEGIN TRY

		IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE LoginName = @LoginName)
			BEGIN
				RAISERROR ('The LoginName already exists. Please use a different LoginName', 16, 1)
			END
		
		SET @UserRoleID	= (SELECT UserRoleID FROM dict.tblUserRole WHERE UserRoleName = @UserRoleName)

		IF @UserRoleID IS NULL
			BEGIN
				RAISERROR ('There is no corresponding value in DB for @UserRoleName = %s', 16, 1, @UserRoleName)
			END
		
		BEGIN TRAN
					
			INSERT INTO dbo.tblUser
			(
				 [UserRoleID]      
				,[LoginName]       
				,[PasswordHash]    
				,[PasswordSalt]    
				,[PhoneNumber]     
				,[Email]           
				,[FirstName]       
				,[LastName]        
				,[IsBusinessClient]
				,[CompanyName]     
				,[NIP]             
				,[IsDeliveryActive]
			)
			VALUES
			(        
				 @UserRoleID      
				,@LoginName      
				,@PasswordHash    
				,@PasswordSalt    
				,@PhoneNumber     
				,@Email           
				,@FirstName    
				,@LastName        
				,@IsBusinessClient
				,@CompanyName    
				,@NIP     
				,@IsDeliveryActive
			)

			SET @UserID = SCOPE_IDENTITY()
		
		COMMIT

	END TRY
	BEGIN CATCH

		SET @UserID = NULL
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