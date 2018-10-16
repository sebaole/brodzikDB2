CREATE TABLE [dict].[tblProductCategory]
(
	[CategoryID]   SMALLINT IDENTITY (1, 1) NOT NULL ,
	[CategoryName] NVARCHAR(64) NOT NULL ,
	[Description]  NVARCHAR(128) NULL ,
	CONSTRAINT [PK_tblProductCategory] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);
GO