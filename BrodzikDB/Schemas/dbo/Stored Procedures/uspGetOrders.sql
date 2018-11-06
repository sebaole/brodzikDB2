CREATE PROCEDURE [dbo].[uspGetOrders]
(
	@LoginName			NCHAR(9) = NULL
	,@OrderDateFrom		DATETIME = NULL
	,@OrderDateTo		DATETIME = NULL
	,@DeliveryDateFrom	DATETIME = NULL
	,@DeliveryDateTo	DATETIME = NULL
	,@OrderStatusCode	NVARCHAR(16) = NULL
	,@OrderNr			NVARCHAR(16) = NULL
	,@OrderID			INT = NULL
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0

	BEGIN TRY

		/* some extra validations here */
		IF NOT EXISTS (SELECT 1 FROM dict.tblOrderStatus WHERE StatusCode = @OrderStatusCode)
			BEGIN
				RAISERROR ('Incorrect value for @OrderStatusCode = %s', 16, 1, @OrderStatusCode)
			END
		
		BEGIN TRAN

			/* target sql statements here */
			;WITH CTE_OrderItems AS
			(
			SELECT
				OrderID
				,[OrderItemsDistinct] = COUNT(*)
				,[OrderItemsTotal] = SUM(Quantity)
			FROM dbo.tblOrderItem
			GROUP BY OrderID
			)

			SELECT 
				O.OrderID
				,O.OrderNr
				,O.OrderDate
				,O.IsSelfPickup
				,O.DeliveryDate
				,[OrderStatus] = OS.StatusCode
				,[OrderStatusDesc] = OS.Description
				,U.LastName
				,U.FirstName
				,U.CompanyName
				,U.IsBusinessClient
				,O.TotalPrice
				,O.TotalPriceWithDiscount
				,OI.OrderItemsDistinct
				,OI.OrderItemsTotal
				-- ???
			FROM dbo.tblOrder O
			LEFT JOIN dbo.vwOrderLatestStatus OS
				ON O.OrderID = OS.OrderID
			INNER JOIN dbo.tblUser U
				ON O.UserID = U.UserID
			LEFT JOIN CTE_OrderItems OI
				ON O.OrderID = OI.OrderID
			WHERE 
				(U.LoginName = @LoginName OR @LoginName IS NULL)
				AND (OS.StatusCode = @OrderStatusCode OR @OrderStatusCode IS NULL)
				AND (O.DeliveryDate >= @DeliveryDateFrom OR @DeliveryDateFrom IS NULL)
				AND (O.DeliveryDate < DATEADD(DAY, 1 , CAST(@DeliveryDateTo AS DATE)) OR @DeliveryDateTo IS NULL)
				AND (O.OrderDate >= @OrderDateFrom OR @OrderDateFrom IS NULL)
				AND (O.OrderDate < DATEADD(DAY, 1 , CAST(@OrderDateTo AS DATE)) OR @OrderDateTo IS NULL)
				AND (O.OrderID = @OrderID OR @OrderID IS NULL)
				AND (O.OrderNr = @OrderNr OR @OrderNr IS NULL)
		
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