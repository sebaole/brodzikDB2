CREATE PROCEDURE [dbo].[uspAddOrderHistoryStatus]
(
	 @OrderID				INT
	,@StatusCode			NVARCHAR(16)
	,@ReasonDisapproved		NVARCHAR(256) = NULL
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue				SMALLINT = 0
		,@OrderStatusID				TINYINT
		,@NewStatusSortOrder		TINYINT
		,@CurrentStatusSortOrder	TINYINT
		,@CurrentStatusCode			NVARCHAR(16)

	BEGIN TRY

		/* some extra validations here */
		SELECT @OrderStatusID = OrderStatusID, @NewStatusSortOrder = SortOrder FROM dict.tblOrderStatus WHERE StatusCode = @StatusCode
		SELECT @CurrentStatusSortOrder = D.SortOrder, @CurrentStatusCode = L.StatusCode FROM dbo.vwOrderLatestStatus L INNER JOIN dict.tblOrderStatus D  ON L.StatusCode = D.StatusCode WHERE L.OrderID = @OrderID


		IF @StatusCode IS NULL OR @OrderStatusID IS NULL
			BEGIN
				RAISERROR ('Incorrect value for @StatusCode = %s', 16, 1, @StatusCode)
			END

		/* not able to set the lower state */
		IF  @NewStatusSortOrder <= @CurrentStatusSortOrder
			BEGIN
				RAISERROR ('The status you are trying to set is less or equal than the current one', 16, 1)
			END

		IF @CurrentStatusCode = 'REJECTED'
			BEGIN
				RAISERROR ('You can not modify the status of rejected order', 16, 1)
			END
			
		BEGIN TRAN
					
			/* target sql statements here */
			/* populate tblOrderHistory */ 
			INSERT INTO dbo.tblOrderHistory
			(
				 OrderID
				,OrderStatusID
				,ReasonDisapproved
			)
			VALUES
			(
				 @OrderID
				,@OrderStatusID
				,@ReasonDisapproved
			)
		
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