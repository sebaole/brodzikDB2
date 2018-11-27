CREATE TABLE [dbo].[tblOrderItem]
(
	[OrderItemID]				INT IDENTITY (1, 1) NOT NULL ,
	[OrderID]					INT NOT NULL ,
	[ProductID]					INT NOT NULL ,
	[ProductName]				NVARCHAR(128) NOT NULL ,
	[Quantity]					TINYINT NOT NULL ,
	[UnitPrice]					MONEY NOT NULL ,
	[VATRate]					DECIMAL(5,4) NOT NULL ,
	[GrossPriceWithDiscount]	MONEY NOT NULL,
	[UserDiscountRate]			DECIMAL(5,4) NULL ,
	[ProductDiscountRate]		DECIMAL(5,4) NULL ,
	[DateCreated]				DATETIME NOT NULL DEFAULT GETDATE(),
	[LastUpdated]				DATETIME NULL ,
	CONSTRAINT [PK_tblOrderItem] PRIMARY KEY CLUSTERED ([OrderItemID] ASC)
);
GO

CREATE TRIGGER [dbo].[trgOrderItem] ON [dbo].[tblOrderItem]
AFTER UPDATE

AS

BEGIN
	SET	NOCOUNT ON

    UPDATE	X
    SET
         LastUpdated = GETDATE()
		--,ModUser = SYSTEM_USER
	FROM [dbo].[tblOrderItem] X
	INNER JOIN inserted I
		ON	I.[OrderItemID] = X.[OrderItemID]
END
GO