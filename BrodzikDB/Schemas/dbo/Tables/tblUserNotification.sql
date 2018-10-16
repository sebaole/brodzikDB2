-- ************************************** [dbo].[tblUserNotification]

CREATE TABLE [dbo].[tblUserNotification]
(
 [UserNotificationID] INT IDENTITY (1, 1) NOT NULL ,
 [UserID]             INT NOT NULL ,
 [UserPhoneNumber]    NCHAR(9) NULL ,
 [UserEmail]          NVARCHAR(256) NULL ,
 [Message]            NVARCHAR(160) NOT NULL ,
 [DateSent]           DATETIME NOT NULL ,

 CONSTRAINT [PK_tblUserNotification] PRIMARY KEY CLUSTERED ([UserNotificationID] ASC)
);
GO