CREATE PROCEDURE [report].[uspGetProductsForDeliveryDate]
(
	 @DeliveryDate		DATETIME
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
				,C.CategoryName
				,OI.ProductName
				,[SumQuantity] = SUM(OI.Quantity)
				,[NrOfOrders] = COUNT(*)
			FROM dbo.tblOrder O
			INNER JOIN dbo.tblOrderItem OI
				ON O.OrderID = OI.OrderID
			LEFT JOIN dbo.tblProduct P
				INNER JOIN dict.tblProductCategory C
					ON P.CategoryID = C.CategoryID
			ON OI.ProductID = P.ProductID
			LEFT JOIN dbo.vwOrderLatestStatus LS
				ON O.OrderID = LS.OrderID
				AND LS.StatusCode NOT IN ('REJECTED')
				--AND LS.IsToDo = 1
			WHERE O.OrderDate = @DeliveryDate
			GROUP BY 
				O.DeliveryDate
				,OI.ProductName
				,C.CategoryName
			ORDER BY 	
				O.DeliveryDate
				,C.CategoryName
				,OI.ProductName
		
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