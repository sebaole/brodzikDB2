-- ************************************** [log].[tblApplicationEventLog]

CREATE TABLE [log].[tblApplicationEventLog]
(
 [EventID]      BIGINT IDENTITY (1, 1) NOT NULL ,
 [EventDate]    DATETIME NOT NULL ,
 [EventMessage] NVARCHAR(128) NOT NULL ,
 [ErrorMessage] NVARCHAR(128) NULL ,
 [UserID]       INT NOT NULL ,

 CONSTRAINT [PK_tblApplicationEventLog] PRIMARY KEY CLUSTERED ([EventID] ASC)
);
GO