-- ************************************** [log].[tblApplicationEventLog]

CREATE TABLE [log].[tblApplicationEventLog]
(
 [EventID]      BIGINT IDENTITY (1, 1) NOT NULL ,
 [EventDate]    DATETIME NOT NULL ,
 [EventMessage] NVARCHAR(1024) NOT NULL ,
 [ErrorMessage] NVARCHAR(1024) NULL ,
 [LoginName]	NVARCHAR(16) NOT NULL,

 CONSTRAINT [PK_tblApplicationEventLog] PRIMARY KEY CLUSTERED ([EventID] ASC)
);
GO