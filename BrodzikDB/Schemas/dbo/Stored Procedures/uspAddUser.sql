CREATE PROCEDURE [dbo].[uspAddUser]
(
	 @UserRoleName				NVARCHAR(16) 
	,@LoginName					NCHAR(9)
	,@PasswordHash				NVARCHAR(128)
	,@PasswordSalt				NVARCHAR(128)
	,@PhoneNumber				NCHAR(9)
	,@Email						NVARCHAR(256) = NULL
	,@FirstName					NVARCHAR(150) = NULL
	,@LastName					NVARCHAR(150) = NULL
	,@IsBusinessClient			BIT
	,@CompanyName				NVARCHAR(256) = NULL
	,@NIP						NCHAR(10) = NULL
	,@IsDeliveryActive			BIT = 0
	,@IsWholesalePriceActive	BIT = 0
	,@IsGDPRAccepted			BIT = 0
	,@IsMarketingAccepted		BIT = 0
	,@IsKDR						BIT = 0
	,@IsActive					BIT = 1
	,@UserID					INT OUTPUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@UserRoleID				TINYINT
		,@ReturnValue			SMALLINT = 0

	BEGIN TRY

		IF EXISTS (SELECT 1 FROM dbo.tblUser WHERE LoginName = @LoginName) AND @UserID IS NULL -- do not check if update is calling
			BEGIN
				RAISERROR ('Ten Login już istnieje. Proszę użyć innego', 16, 1)
			END

		IF @UserID IS NOT NULL AND (NOT EXISTS (SELECT 1 FROM dbo.tblUser WHERE UserID = @UserID) OR (SELECT LoginName FROM dbo.tblUser WHERE UserID = @UserID) <> @LoginName)
			BEGIN
				RAISERROR ('Login jest inny niż wskazuje na to UserID', 16, 1)
			END
		
		SET @UserRoleID	= (SELECT UserRoleID FROM dict.tblUserRole WHERE UserRoleName = @UserRoleName)

		IF @UserRoleID IS NULL
			BEGIN
				RAISERROR ('Nieprawidłowa wartość dla parametru @UserRoleName = %s', 16, 1, @UserRoleName)
			END
		
		BEGIN TRAN
			
			IF @UserID IS NULL
				BEGIN
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
					,[IsWholesalePriceActive]
					,[IsGDPRAccepted]
					,[IsMarketingAccepted]
					,[IsKDR]
					,[IsActive]
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
					,@IsWholesalePriceActive
					,@IsGDPRAccepted
					,@IsMarketingAccepted
					,@IsKDR
					,@IsActive
				)

				SET @UserID = SCOPE_IDENTITY()
				END
			ELSE
				BEGIN
					UPDATE dbo.tblUser
					SET
						 [UserRoleID] = IIF(UserRoleID = 1, UserRoleID, @UserRoleID) -- to prevent for not changing admin into client									
						,[PhoneNumber] = @PhoneNumber
						,[Email] = @Email					
						,[FirstName] = @FirstName				
						,[LastName] = @LastName	
						,[IsBusinessClient] = @IsBusinessClient	
						,[CompanyName] = @CompanyName				
						,[NIP] = @NIP						
						,[IsWholesalePriceActive] = @IsWholesalePriceActive	
						,[IsDeliveryActive] = @IsDeliveryActive
						,[IsGDPRAccepted] = @IsGDPRAccepted	
						,[IsMarketingAccepted] = @IsMarketingAccepted
						,[IsKDR] = @IsKDR
						,[IsActive] = @IsActive
					WHERE UserID = @UserID AND LoginName = @LoginName -- double check
				END
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