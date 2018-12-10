CREATE PROCEDURE [report].[uspGetDeliveryAddress]
(
	@DeliveryDate DATETIME = NULL
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
				O.DeliveryDate
				,O.OrderNr
				,[DeliveryAddress] = CONCAT(O.DeliveryCity, ' ', O.DeliveryZipCode, ', ', O.DeliveryStreet, ' ', O.DeliveryNumberLine1, IIF(NULLIF(O.DeliveryNumberLine2, '') IS NULL, NULL, '/'), O.DeliveryNumberLine2)
				,[ClientName] = IIF(U.IsBusinessClient = 1, U.CompanyName, CONCAT(U.LastName,' ',U.FirstName))
				,[ContactPhoneNumber] = O.ContactPhoneNumber
				,[ContactPerson] = CONCAT(O.ContactPersonLastName, ' ', O.ContactPersonFirstName)
			FROM dbo.tblOrder O
			INNER JOIN dbo.tblUser U
				ON O.UserID = U.UserID
			WHERE 
				O.IsSelfPickup = 0
				AND (O.DeliveryDate = @DeliveryDate OR @DeliveryDate IS NULL)
			ORDER BY 
				O.DeliveryDate DESC
				,ClientName ASC
				,DeliveryAddress ASC
		
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
