-- ************************************** [dbo].[tblOrderNotification]

CREATE TABLE [dbo].[tblOrderNotification]
(
 [OrderNotificationID] INT IDENTITY (1, 1) NOT NULL ,
 [OrderHistoryID]      INT NOT NULL ,
 [UserPhoneNumber]     NCHAR(9) NULL ,
 [UserEmail]           NVARCHAR(256) NULL ,
 [Message]             NVARCHAR(160) NOT NULL ,
 [DateSent]            DATETIME NOT NULL ,

 CONSTRAINT [PK_tblNotification] PRIMARY KEY CLUSTERED ([OrderNotificationID] ASC)
);
GO