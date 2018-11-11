﻿CREATE PROCEDURE [dbo].[uspGetOrderDetails]
(
	@OrderNr	NVARCHAR(16)
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		IF NOT EXISTS (SELECT 1 FROM dbo.tblOrder WHERE OrderNr = @OrderNr)
			BEGIN
				RAISERROR ('Order Number %s does not exist', 16, 1, @OrderNr)
			END
		
		BEGIN TRAN

			/* target sql statements here */
			SELECT 
				O.OrderID
				,O.OrderNr
				,O.OrderDate
				,O.IsSelfPickup
				,O.DeliveryDate
				,O.CustomerNote
				,O.DateInvoiced
				,O.DeliveryState
				,O.DeliveryCity
				,O.DeliveryZipCode		
				,O.DeliveryStreet
				,O.DeliveryNumberLine1
				,O.DeliveryNumberLine2
			FROM dbo.tblOrder O
			INNER JOIN dbo.tblUser U
				ON O.UserID = U.UserID
			WHERE 
				O.OrderNr = @OrderNr
		
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