CREATE PROCEDURE [dbo].[uspGetAddress]
(
	 @LoginName			NVARCHAR(16)
	 ,@IsActive			BIT = NULL
	 ,@IsMainAddress	BIT = NULL
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
				 A.[AddressID]
				,A.[Street]
				,A.[NumberLine1]
				,A.[NumberLine2]
				,A.[City]
				,A.[State]
				,A.[ZipCode]
				,A.[ContactPersonLastName]
				,A.[ContactPersonFirstName]
				,A.[ContactPhoneNumber]
				,A.[IsMainAddress]
				,A.[IsActive]				
			FROM dbo.tblAddress A
			INNER JOIN dbo.tblUser U
				ON A.UserID = U.UserID
			WHERE 
				U.LoginName = @LoginName
				AND (A.IsActive = @IsActive OR @IsActive IS NULL)
				AND (A.IsMainAddress = @IsMainAddress OR @IsMainAddress IS NULL)

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