CREATE PROCEDURE [report].[uspGetDeliveryDateDetails]
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
			;WITH CTE_TotalPrice AS
			(
			SELECT 
				OrderID
				,[TotalPrice] = SUM(GrossPriceWithDiscount)
			FROM dbo.tblOrderItem
			GROUP BY OrderID
			)
			
			SELECT
				O.OrderNr
				,O.IsSelfPickup
				,[TotalPrice] = TP.TotalPrice
				,[OrderStatus] = LS.Description
				,[ClientName] = IIF(U.IsBusinessClient = 1, U.CompanyName, CONCAT(U.LastName, ' ', U.FirstName))
			FROM dbo.tblOrder O
			INNER JOIN dbo.tblUser U
				ON O.UserID = U.UserID
			INNER JOIN dbo.vwOrderLatestStatus LS
				ON O.OrderID = LS.OrderID
			INNER JOIN CTE_TotalPrice TP
				ON O.OrderID = TP.OrderID
			WHERE (O.DeliveryDate = @DeliveryDate OR @DeliveryDate IS NULL)
			ORDER BY O.OrderNr DESC
		
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