CREATE PROCEDURE [dbo].[uspGetOrderItems]
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
				RAISERROR ('Zamówienie nr %s nie istnieje', 16, 1, @OrderNr)
			END
		
		BEGIN TRAN

			/* target sql statements here */
			SELECT 
				O.OrderID
				,O.OrderNr
				,OI.ProductID
				,OI.ProductName
				,OI.Quantity
				,OI.UnitPrice
				,OI.VATRate
				,C.CategoryName
				--,[GrossPrice] = ROUND((OI.VATRate * OI.[UnitPrice]) + OI.[UnitPrice], 2)
				,[GrossPrice] = OI.GrossPriceWithDiscount
				,[GrossPriceTotal] = OI.GrossPriceWithDiscount * OI.Quantity
			FROM dbo.tblOrder O
			INNER JOIN dbo.tblOrderItem OI
				ON O.OrderID = OI.OrderID
			LEFT JOIN dbo.tblProduct P
				ON OI.ProductID = P.ProductID
			LEFT JOIN dict.tblProductCategory C
				ON P.CategoryID = C.CategoryID
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