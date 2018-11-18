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
	,@IsMainAddress          BIT = 1
	,@IsActive				 BIT = 1
	,@AddressID				 INT = NULL
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue		SMALLINT = 0
		,@UserID			INT
		,@UserIDAddressID	INT

	SET @UserID = (SELECT UserID FROM dbo.tblUser WHERE LoginName = @LoginName)
	SET @UserIDAddressID = (SELECT UserID FROM dbo.tblAddress WHERE AddressID = @AddressID)

	BEGIN TRY

		/* some extra validations here */
		IF @AddressID IS NOT NULL AND (@UserIDAddressID IS NULL OR @UserID IS NULL)
		BEGIN
			RAISERROR('LoginName or AddressID you passed does not exist', 16, 1)
		END

		IF @AddressID IS NOT NULL AND @UserIDAddressID <> @UserID
		BEGIN
			RAISERROR('AddressID does not match LoginName you passed', 16, 1)
		END

		BEGIN TRAN
					
			/* target sql statements here */

			/* if new main adress is passed then update existing ones */
			IF @IsMainAddress = 1
			BEGIN
				UPDATE dbo.tblAddress
				SET IsMainAddress = 0
				WHERE UserID = @UserID
			END

			IF @AddressID IS NULL
				BEGIN

					/* first added address must be main */
					IF @IsMainAddress = 0 AND NOT EXISTS (SELECT 1 FROM dbo.tblAddress WHERE UserID = @UserID) 
					BEGIN
						SET @IsMainAddress = 1
					END

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