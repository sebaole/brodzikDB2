-- ************************************** [dbo].[tblProduct]
CREATE TABLE [dbo].[tblProduct]
(
	 [ProductID]			INT IDENTITY (1,1) NOT NULL 
	,[CategoryID]			SMALLINT NOT NULL 
	,[ProductName]			NVARCHAR(128) NOT NULL 
	,[ShortDescription]		NVARCHAR(64) NOT NULL 
	,[LongDescription]		NVARCHAR(256) NOT NULL 
	,[Ingredients]			NVARCHAR(256) NOT NULL 
	,[Weight]				DECIMAL(10,2) NOT NULL 
	,[UnitOfWeight]			NVARCHAR(8) NOT NULL 
	--,[UnitPrice]        MONEY NOT NULL 
	,[UnitRetailPrice]		MONEY NOT NULL
	,[UnitWholesalePrice]	MONEY NOT NULL
	,[VATID]				TINYINT NOT NULL 
	,[IsMonday]				BIT NOT NULL 
	,[IsTuesday]			BIT NOT NULL 
	,[IsWednesday]			BIT NOT NULL 
	,[IsThursday]			BIT NOT NULL 
	,[IsFriday]				BIT NOT NULL 
	,[IsSaturday]			BIT NOT NULL 
	,[IsSunday]				BIT NOT NULL 
	,[DateCreated]			DATETIME NOT NULL  DEFAULT GETDATE()
	,[LastUpdated]			DATETIME NULL 
	,CONSTRAINT [PK_tblProduct] PRIMARY KEY CLUSTERED ([ProductID] ASC)

);
GO