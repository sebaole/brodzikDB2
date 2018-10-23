﻿CREATE TABLE [log].[tblLogSMS]
(
	LogID		INT IDENTITY(1,1) NOT NULL,
	PhoneNo		NVARCHAR(9) NOT NULL,
	Msg			NVARCHAR(500) NOT NULL,
	DateSent	DATETIME NOT NULL DEFAULT GETDATE(),
	Status		NVARCHAR(1500) NOT NULL
)
GO