-- ************************************** [dbo].[tblProduct]
CREATE TABLE [dbo].[tblProduct]
(
	 [ProductID]			INT IDENTITY (1,1) NOT NULL 
	,[CategoryID]			SMALLINT NOT NULL 
	,[ProductName]			NVARCHAR(128) NOT NULL 
	,[ShortDescription]		NVARCHAR(64) NULL 
	,[LongDescription]		NVARCHAR(256) NULL 
	,[Ingredients]			NVARCHAR(256) NOT NULL 
	,[Weight]				DECIMAL(10,2) NOT NULL 
	,[UnitOfWeight]			NVARCHAR(8) NOT NULL 
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
	,[IsActive]				BIT NOT NULL
	,[DateCreated]			DATETIME NOT NULL  DEFAULT GETDATE()
	,[LastUpdated]			DATETIME NULL 
	,CONSTRAINT [PK_tblProduct] PRIMARY KEY CLUSTERED ([ProductID] ASC)

);
GO

CREATE TRIGGER [dbo].[trgProduct] ON [dbo].[tblProduct]
AFTER UPDATE

AS

BEGIN
	SET	NOCOUNT ON

    UPDATE	X
    SET
         LastUpdated = GETDATE()
		--,ModUser = SYSTEM_USER
	FROM [dbo].[tblProduct] X
	INNER JOIN inserted I
		ON	I.[ProductID] = X.[ProductID]
END
GO