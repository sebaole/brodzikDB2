CREATE TABLE [dict].[tblProductCategory]
(
	[CategoryID]		SMALLINT IDENTITY (1, 1) NOT NULL ,
	[CategoryName]		NVARCHAR(64) NOT NULL ,
	[Description]		NVARCHAR(128) NULL ,
	[IsKDRActive]		BIT NOT NULL DEFAULT(0),
	[KDRGrossDiscount]	MONEY NOT NULL DEFAULT(0)
	CONSTRAINT [PK_tblProductCategory] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);
GO