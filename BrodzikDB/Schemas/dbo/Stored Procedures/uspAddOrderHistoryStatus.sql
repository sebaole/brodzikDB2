﻿CREATE PROCEDURE [dbo].[uspAddOrderHistoryStatus]
(
	 @OrderID				INT 
	,@StatusCode			NVARCHAR(16)
	,@ReasonDisapproved		NVARCHAR(256)
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue	SMALLINT = 0
		,@OrderStatusID	TINYINT

	BEGIN TRY

		/* some extra validations here */
		SET @OrderStatusID = (SELECT OrderStatusID FROM dict.tblOrderStatus WHERE StatusCode = @StatusCode)
		IF @StatusCode IS NULL
			BEGIN
				RAISERROR ('Incorrect value for @StatusCode = %s', 16, 1, @StatusCode)
			END
		
		BEGIN TRAN
					
			/* target sql statements here */
			/* populate tblOrderHistory */ 
			INSERT INTO dbo.tblOrderHistory
			(
				 OrderID
				,OrderStatusID
			)
			VALUES
			(
				 @OrderID
				,@OrderStatusID
			)

			IF @StatusCode = 'CANCEL'
				BEGIN
					UPDATE dbo.tblOrder
					SET ReasonDisapproved = @ReasonDisapproved  -- move into dbo.tblOrderHistory as a comment?
					WHERE OrderID = @OrderID
				END
		
		COMMIT

	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		DECLARE
			 @ErrorMessage	NVARCHAR(4000)
			,@ErrorSeverity	INT
			,@ErrorState	INT

		SET @ErrorMessage	= ERROR_MESSAGE()
		SET @ErrorSeverity	= ERROR_SEVERITY()
		SET @ErrorState		= ERROR_STATE()

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)

	END CATCH

RETURN @ReturnValue

END