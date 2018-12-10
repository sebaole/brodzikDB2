CREATE PROCEDURE [dbo].[uspUpdateOrder]
(
	 @OrderNr				NVARCHAR(16)
	,@IsInvoiced			BIT = NULL
	,@IsSelfPickup			BIT = NULL
	,@IsRecurring			BIT = NULL
	,@RecurrenceWeekNumber	TINYINT = NULL
	,@DateEndRecurring		DATETIME = NULL
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		IF @IsRecurring = 1 AND (@RecurrenceWeekNumber IS NULL OR @DateEndRecurring IS NULL)
			BEGIN
				RAISERROR('Niewystarczająca liczba parametrów dla zamówienia cyklicznego', 16, 1)
			END
		
		BEGIN TRAN
					
			/* target sql statements here */
			UPDATE dbo.tblOrder
			SET
				 [IsInvoiced]			= ISNULL(@IsInvoiced, IsInvoiced)
				,[DateInvoiced]			= CASE 
											WHEN @IsInvoiced = 1 THEN GETDATE()
											WHEN @IsInvoiced = 0 THEN NULL
											ELSE IsInvoiced 
										END
				,[IsSelfPickup]			= ISNULL(@IsSelfPickup ,IsSelfPickup)
				,[IsRecurring]			= ISNULL(@IsRecurring ,IsRecurring)
				,[RecurrenceWeekNumber]	= ISNULL(@RecurrenceWeekNumber ,RecurrenceWeekNumber)
				,[DateEndRecurrence]	= ISNULL(@DateEndRecurring ,DateEndRecurrence)
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