CREATE PROCEDURE [dbo].[uspGetUserDetails]
(
	 @LoginName		NVARCHAR(9) = NULL
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
				U.UserID
				,U.LastName
				,U.FirstName
				,U.LoginName
				,U.PhoneNumber
				,U.Email
				,U.IsBusinessClient
				,U.IsMarketingAccepted
				,U.IsGDPRAccepted
				,U.IsDeliveryActive
				,U.IsWholesalePriceActive
				,U.CompanyName
				,U.NIP
				,U.DateCreated
				,UR.UserRoleName
				,A.City
				,A.ZipCode
				,A.State
				,A.Street
				,A.NumberLine1
				,A.NumberLine2
			FROM dbo.tblUser U
			INNER JOIN dict.tblUserRole UR
				ON U.UserRoleID = UR.UserRoleID
			LEFT JOIN dbo.tblAddress A
				ON U.UserID = A.UserID
					AND A.IsMainAddress = 1
					AND A.IsActive = 1
			WHERE LoginName = @LoginName OR @LoginName IS NULL

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