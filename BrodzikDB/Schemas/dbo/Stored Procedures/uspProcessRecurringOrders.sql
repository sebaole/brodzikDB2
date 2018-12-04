CREATE PROCEDURE [dbo].[uspProcessRecurringOrders]
(
	  @DeliveryDate			DATETIME
	 ,@OrdersAddedCount		INT OUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue					SMALLINT = 0
		,@OriginOrderID					INT
		,@OriginOrderDate				DATETIME	
		,@OriginRecurrenceWeekNumber	TINYINT		
		,@OriginLoginName				NVARCHAR(9)
		,@OriginIsSelfPickup			BIT
		,@OriginCustomerNote			NVARCHAR(256)
		,@OriginDeliveryCity			NVARCHAR(64)
		,@OriginDeliveryState			NVARCHAR(64)
		,@OriginDeliveryZipCode			NVARCHAR(6)
		,@OriginDeliveryStreet			NVARCHAR(128)
		,@OriginDeliveryNumberLine1		NVARCHAR(16)
		,@OriginDeliveryNumberLine2		NVARCHAR(16)
		,@OriginDeliveryDate			DATETIME
		,@NewCustomerNote				NVARCHAR(256)
		--,@DeliveryDateCounter			DATETIME
		,@IntCounter					INT
		,@outOrderID					INT
		,@outOrderNr					NVARCHAR(16)
		,@OrderCounter					INT = 0

	BEGIN TRY

		/* some extra validations here */
		
		BEGIN TRAN
					
			/* target sql statements here */
			/* step1 - get all not expired, recurring, not cancelled orders that has not been created yet */
			IF OBJECT_ID('tempdb..#tempRecurringOrders') IS NOT NULL DROP TABLE #tempRecurringOrders

			SELECT
				 O.OrderID
				,O.OrderDate
				,O.RecurrenceWeekNumber
				,U.LoginName				
				,O.IsSelfPickup			
				,O.CustomerNote			
				,O.DeliveryCity			
				,O.DeliveryState			
				,O.DeliveryZipCode		
				,O.DeliveryStreet		
				,O.DeliveryNumberLine1	
				,O.DeliveryNumberLine2	
				,O.DeliveryDate
			INTO #tempRecurringOrders
			FROM dbo.tblOrder O
			INNER JOIN dbo.tblUser U
				ON O.UserID = U.UserID
			LEFT JOIN dbo.vwOrderLatestStatus LS
				ON O.OrderID = LS.OrderID
			WHERE 
				IsRecurring = 1
				AND DateEndRecurrence >= @DeliveryDate
				AND LS.StatusCode NOT IN ('REJECTED','DELETED')
				AND NOT EXISTS (SELECT 1 
								FROM dbo.tblOrder O2 
								WHERE 
									O2.RecurrenceBaseOrderID = O.OrderID 
									AND O2.DeliveryDate = @DeliveryDate
								)
			

			/* step2 - go through all orders and check if it matched to provided @DeliveryDate */
			IF CURSOR_STATUS('local','sqlCursorForOrders') >= -1
			BEGIN
				DEALLOCATE sqlCursorForOrders
			END

			DECLARE sqlCursorForOrders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
			SELECT 
				OrderID
				,OrderDate
				,RecurrenceWeekNumber
				,LoginName				
				,IsSelfPickup			
				,CustomerNote			
				,DeliveryCity			
				,DeliveryState			
				,DeliveryZipCode		
				,DeliveryStreet		
				,DeliveryNumberLine1	
				,DeliveryNumberLine2	
				,DeliveryDate
			FROM #tempRecurringOrders
			
			OPEN sqlCursorForOrders

			FETCH NEXT FROM sqlCursorForOrders
			INTO 
				 @OriginOrderID
				,@OriginOrderDate
				,@OriginRecurrenceWeekNumber
				,@OriginLoginName				
				,@OriginIsSelfPickup			
				,@OriginCustomerNote			
				,@OriginDeliveryCity			
				,@OriginDeliveryState			
				,@OriginDeliveryZipCode		
				,@OriginDeliveryStreet		
				,@OriginDeliveryNumberLine1	
				,@OriginDeliveryNumberLine2	
				,@OriginDeliveryDate

			WHILE @@FETCH_STATUS = 0
			   BEGIN
					/* extra loop here */
					SET @IntCounter = 1

					WHILE DATEADD(WEEK, @OriginRecurrenceWeekNumber * @IntCounter, @OriginDeliveryDate) <= @DeliveryDate
						BEGIN
							IF DATEADD(WEEK, @OriginRecurrenceWeekNumber * @IntCounter, @OriginDeliveryDate) = @DeliveryDate
								BEGIN
									SET @NewCustomerNote = CONCAT('[Utworzone automatycznie] ', @OriginCustomerNote)

									EXEC [dbo].[uspAddOrder]
											 @LoginName = @OriginLoginName
											,@DeliveryDate = @DeliveryDate
											,@IsSelfPickup = @OriginIsSelfPickup
											,@CustomerNote = @NewCustomerNote
											,@DeliveryCity = @OriginDeliveryCity
											,@DeliveryState = @OriginDeliveryState
											,@DeliveryZipCode = @OriginDeliveryZipCode
											,@DeliveryStreet = @OriginDeliveryStreet
											,@DeliveryNumberLine1 = @OriginDeliveryNumberLine1
											,@DeliveryNumberLine2 = @OriginDeliveryNumberLine2
											,@RecurrenceBaseOrderID = @OriginOrderID
											,@OrderID = @outOrderID OUTPUT
											,@OrderNr = @outOrderNr OUTPUT

										SET @OrderCounter = @OrderCounter + 1
								END
							SET @IntCounter = @IntCounter + 1
						END

			      	FETCH NEXT FROM sqlCursorForOrders
					INTO 
						 @OriginOrderID
						,@OriginOrderDate
						,@OriginRecurrenceWeekNumber
						,@OriginLoginName				
						,@OriginIsSelfPickup			
						,@OriginCustomerNote			
						,@OriginDeliveryCity			
						,@OriginDeliveryState			
						,@OriginDeliveryZipCode		
						,@OriginDeliveryStreet		
						,@OriginDeliveryNumberLine1	
						,@OriginDeliveryNumberLine2 
						,@OriginDeliveryDate
			   END
			
		COMMIT

		CLOSE sqlCursorForOrders
		DEALLOCATE sqlCursorForOrders
			
		SET @OrdersAddedCount = @OrderCounter

	END TRY
	BEGIN CATCH

		SET @ReturnValue = -1
		SET @OrdersAddedCount = 0

		IF CURSOR_STATUS('local','sqlCursorForOrders') >= -1
			BEGIN
				DEALLOCATE sqlCursorForOrders
			END

		IF @@TRANCOUNT > 0 ROLLBACK TRAN
  
		/* raise an error */
		;THROW

	END CATCH

RETURN @ReturnValue

END