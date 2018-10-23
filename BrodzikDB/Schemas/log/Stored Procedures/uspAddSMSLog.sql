CREATE PROCEDURE [log].[uspAddSMSLog]
(
	 @PhoneNumber	NCHAR(9)
	,@Message		NVARCHAR(500)
	,@Status		NVARCHAR(1500)
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
			INSERT INTO log.tblLogSMS
			(
				PhoneNo
				,Msg
				,Status
			)
			VALUES
			(
				@PhoneNumber
				,@Message
				,@Status
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