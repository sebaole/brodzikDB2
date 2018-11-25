CREATE PROCEDURE [dbo].[uspUpdateOrder]
(
	 @OrderNr			NVARCHAR(16)
	 ,@IsInvoiced		BIT
	 --,@IsSelfPickup		BIT = NULL
	 --,@DeliveryStreet	NVARCHAR(256) = NULL
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
			UPDATE dbo.tblOrder
			SET
				 IsInvoiced		= @IsInvoiced
				 ,DateInvoiced	= IIF(@IsInvoiced =1 , GETDATE(), NULL)
				--,IsSelfPickup	= ISNULL(@IsSelfPickup, IsSelfPickup)
				--,DeliveryStreet = ISNULL(@DeliveryStreet, DeliveryStreet)
			WHERE OrderNr = @OrderNr
		
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