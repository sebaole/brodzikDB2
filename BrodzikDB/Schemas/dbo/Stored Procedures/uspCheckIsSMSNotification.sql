CREATE PROCEDURE [dbo].[uspCheckIsSMSNotification]
(
	 @StatusCode		NVARCHAR(16)
	,@IsNotificationSMS	BIT OUTPUT
)
AS

BEGIN

	SET	XACT_ABORT, NOCOUNT ON

	DECLARE 
		@ReturnValue		SMALLINT = 0
		,@OrderStatusID		TINYINT

	BEGIN TRY

		/* some extra validations here */
		SELECT @OrderStatusID = OrderStatusID FROM dict.tblOrderStatus WHERE StatusCode = @StatusCode

		IF @StatusCode IS NULL OR @OrderStatusID IS NULL
			BEGIN
				RAISERROR ('Incorrect value for @StatusCode = %s', 16, 1, @StatusCode)
			END
		
		BEGIN TRAN
					
			/* target sql statements here */
			SELECT @IsNotificationSMS = IsNotificationSMS 
			FROM dict.tblOrderStatus 
			WHERE StatusCode = @StatusCode
		
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