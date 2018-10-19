﻿CREATE TABLE [dict].[tblOrderStatus]
(
	[OrderStatusID]       TINYINT IDENTITY (1, 1) NOT NULL ,
	[StatusCode]          NVARCHAR(16) NOT NULL ,
	[Description]         NVARCHAR(32) NOT NULL ,
	[IsNotificationSMS]   BIT NOT NULL ,
	[IsNotificationEmail] BIT NOT NULL ,
	CONSTRAINT [PK_tblOrderStatus] PRIMARY KEY CLUSTERED ([OrderStatusID] ASC)
);
GO