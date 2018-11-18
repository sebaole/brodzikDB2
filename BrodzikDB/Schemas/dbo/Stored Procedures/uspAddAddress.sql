CREATE PROCEDURE [dbo].[uspAddAddress]
(
	 @LoginName              NVARCHAR(16)
	,@Street                 NVARCHAR(128)
	,@NumberLine1            NVARCHAR(16)
	,@NumberLine2            NVARCHAR(16)
	,@City                   NVARCHAR(64)
	,@State                  NVARCHAR(64)
	,@ZipCode                NCHAR(6)
	,@ContactPersonFirstName NVARCHAR(150) = NULL
	,@ContactPersonLastName  NVARCHAR(150) = NULL
	,@ContactPhoneNumber     NVARCHAR(32) = NULL
	,@IsMainAddress          BIT = 0
	,@IsActive				 BIT = 1
	,@IsUpdate				 BIT = 0
	,@AddressID				 INT = NULL
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
		IF @IsUpdate = 1 AND @AddressID IS NULL
		BEGIN
			RAISERROR('You must declare AddressID for update statement', 16, 1)
		END

		IF @AddressID IS NOT NULL AND (SELECT UserID FROM dbo.tblAddress WHERE AddressID = @AddressID) <> (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)
		BEGIN
			RAISERROR('AddressID or LoginName you passed is not correct', 16, 1)
		END
		
		BEGIN TRAN
					
			/* target sql statements here */

			--if new main adress is passed then update existing one 
			IF @IsMainAddress = 1
			BEGIN
				UPDATE dbo.tblAddress
				SET IsMainAddress = 0
				WHERE UserID = @UserID
			END

			IF @IsUpdate = 0
				BEGIN
					INSERT INTO dbo.tblAddress
					(
						 [UserID]                
						,[Street]                
						,[NumberLine1]           
						,[NumberLine2]           
						,[City]                  
						,[State]                 
						,[ZipCode]               
						,[ContactPersonFirstName]
						,[ContactPersonLastName] 
						,[ContactPhoneNumber]    
						,[IsMainAddress]         
						,[IsActive]				
					)
					VALUES
					(
						 @UserID                
						,@Street                
						,@NumberLine1           
						,@NumberLine2           
						,@City                  
						,@State                 
						,@ZipCode               
						,@ContactPersonFirstName
						,@ContactPersonLastName 
						,@ContactPhoneNumber    
						,@IsMainAddress         
						,@IsActive	
					)
				END
			ELSE
				BEGIN
					UPDATE dbo.tblAddress
					SET
						 [Street] = @Street            
						,[NumberLine1] = @NumberLine1      
						,[NumberLine2] = @NumberLine2
						,[City] = @City
						,[State] = @State          
						,[ZipCode] = @ZipCode        
						,[ContactPersonFirstName] = @ContactPersonFirstName
						,[ContactPersonLastName] = @ContactPersonLastName
						,[ContactPhoneNumber] = @ContactPhoneNumber
						,[IsMainAddress] = @IsMainAddress
						,[IsActive] = @IsActive
					WHERE AddressID = @AddressID
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