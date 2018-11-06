CREATE PROCEDURE [dbo].[uspGetShoppingCartDeliveryDates]
(
	  @LoginName			NCHAR(9)
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
		
		BEGIN TRAN
					
			/* target sql statements here */
			SELECT DISTINCT 
				[DeliveryDate] = DeliveryDate -- CAST(DeliveryDate AS DATE)
			FROM dbo.tblShoppingCart SC
			WHERE	
				SC.UserID = @UserID
				AND SC.DateExpired >= GETDATE()

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
