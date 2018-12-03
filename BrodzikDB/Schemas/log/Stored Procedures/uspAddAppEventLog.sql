CREATE PROCEDURE [log].[uspAddAppEventLog]
(
	 @LoginName		NVARCHAR(16)
	,@EventMessage	NVARCHAR(1024)
	,@ErrorMessage	NVARCHAR(1024) = NULL

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
			INSERT INTO log.tblApplicationEventLog
			(
				[EventDate]    
				,[EventMessage] 
				,[ErrorMessage]
				,[LoginName]
			)
			VALUES
			(
				GETDATE()
				,@EventMessage
				,@ErrorMessage
				,@LoginName
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