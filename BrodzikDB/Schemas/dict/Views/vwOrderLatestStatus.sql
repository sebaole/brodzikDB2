CREATE VIEW [dbo].[vwOrderLatestStatus]
AS 
	WITH CTE AS
	(
	SELECT
		 OrderID
		,OrderStatusID
		,DateCreated
		,[RN] = ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY OrderHistoryID ASC)
	FROM dbo.tblOrderHistory
	)

	SELECT
		 H.OrderID
		,H.OrderStatusID
		,S.StatusCode
		,S.Description
		,H.DateCreated
	FROM CTE H
	INNER JOIN dict.tblOrderStatus S
		ON H.OrderStatusID = S.OrderStatusID
	WHERE H.RN = 1