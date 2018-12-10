CREATE PROCEDURE [report].[uspGetDeliveryDateSummary]
(
	 @DeliveryDate		DATETIME = NULL
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
				,[OrderCount] = COUNT(1) 
				,[SelfPickupCount] = SUM(IIF(O.IsSelfPickup = 1, 1, 0))
				,[DeliveryCount] = SUM(IIF(O.IsSelfPickup = 0, 1, 0))
				,[TotalPrice] = SUM(OI.TotalPrice)
			FROM dbo.tblOrder O
			INNER JOIN (
						SELECT 
							OrderID
							,[TotalPrice] = SUM(GrossPriceWithDiscount) 
						FROM dbo.tblOrderItem 
						GROUP BY OrderID
						) OI
				ON O.OrderID = OI.OrderID
			WHERE (O.DeliveryDate = @DeliveryDate OR @DeliveryDate IS NULL)
			GROUP BY O.DeliveryDate 
			ORDER BY O.DeliveryDate DESC
		
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