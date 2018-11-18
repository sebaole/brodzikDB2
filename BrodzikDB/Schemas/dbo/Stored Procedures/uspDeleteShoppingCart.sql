CREATE PROCEDURE [dbo].[uspDeleteShoppingCart]
(
	  @LoginName		NVARCHAR(16)
	 ,@DeliveryDate		DATETIME = NULL
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
			DELETE FROM dbo.tblShoppingCart
			WHERE 
				UserID = @UserID
				AND (DeliveryDate = @DeliveryDate OR @DeliveryDate IS NULL)
		
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