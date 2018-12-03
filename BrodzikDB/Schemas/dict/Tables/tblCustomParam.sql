﻿CREATE TABLE [dict].[tblCustomParam]
(
	[IdParam]		INT IDENTITY(1,1) NOT NULL,
	[ParamName]		NVARCHAR(256) NOT NULL,
	[ParamValue]	NVARCHAR(256) NOT NULL
	CONSTRAINT [PK_tblCustomParam] PRIMARY KEY CLUSTERED ([IdParam] ASC)
);
GO