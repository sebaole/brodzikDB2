CREATE TABLE [dbo].[tblShoppingCart]
(
	 [ShoppingCartID]	INT IDENTITY (1, 1) NOT NULL
	,[UserID]			INT NOT NULL
	,[ProductID]		INT NOT NULL
	,[Quantity]			TINYINT NOT NULL CHECK([Quantity] > 0)
	,[DateCreated]		DATETIME NOT NULL DEFAULT(GETDATE())
	,[ShortDateCreated]	AS CAST([DateCreated] AS DATE) PERSISTED
	,[DateExpired]		DATETIME NOT NULL
	,[LastUpdated]		DATETIME NULL
	,CONSTRAINT [PK_tblShoppingCart] PRIMARY KEY CLUSTERED ([ShoppingCartID] ASC)
);
GO

CREATE UNIQUE INDEX UIX_tblShoppingCart ON [dbo].[tblShoppingCart]([UserID],[ProductID],[ShortDateCreated])

GO

CREATE TRIGGER [dbo].[trgShoppingCart] ON [dbo].[tblShoppingCart]
AFTER UPDATE

AS

BEGIN
	SET	NOCOUNT ON

    UPDATE	X
    SET
         LastUpdated = GETDATE()
		--,ModUser = SYSTEM_USER
	FROM [dbo].[tblShoppingCart] X
	INNER JOIN inserted I
		ON	I.[ShoppingCartID] = X.[ShoppingCartID]
END
GO