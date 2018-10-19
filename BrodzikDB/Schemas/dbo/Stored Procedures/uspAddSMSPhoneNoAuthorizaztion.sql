CREATE PROCEDURE [dbo].[uspAddSMSPhoneNoAuthorizaztion]
(
	 @code			NVARCHAR(6) 
	,@phone			NCHAR(9)
	,@ip			NVARCHAR(100)
	,@typ			INT
)
AS

BEGIN

	INSERT INTO [dbo].[tblPhoneNoConfiramtionSMSCode]
	(
		 [Code]
		,[Phone]
		,[DateSent]
		,[ComputerIP]
		,[typ]
	)
	VALUES
	(
		 @code
		,@phone
		,getdate()
		,@ip
		,@typ
	)

END
GO