﻿CREATE TABLE [dbo].[tblPhoneNoConfiramtionSMSCode]
(
	[SmsID]			INT IDENTITY(1,1) NOT NULL,
	[Code]			NVARCHAR(6) NOT NULL,
	[Phone]			NVARCHAR(9) NOT NULL,
	[DateSent]		DATETIME NOT NULL,
	[ComputerIP]	NVARCHAR(100) NOT NULL,
	CONSTRAINT [PK_tblPhoneNoConfiramtionSMSCode] PRIMARY KEY CLUSTERED ([SmsID] ASC),
)
