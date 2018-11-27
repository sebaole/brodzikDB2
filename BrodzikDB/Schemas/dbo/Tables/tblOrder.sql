CREATE TABLE [dbo].[tblOrder]
(
	[OrderID]                INT IDENTITY (1, 1) NOT NULL ,
	[UserID]                 INT NOT NULL ,
	[OrderNr]                NVARCHAR(16) NOT NULL ,
	[OrderDate]              DATETIME NOT NULL  DEFAULT GETDATE(),
	[DeliveryDate]           DATETIME NOT NULL ,
	[IsSelfPickup]           BIT NOT NULL ,
	[TotalPrice]             MONEY NOT NULL ,
	[TotalPriceWithDiscount] MONEY NOT NULL ,
	[CustomerNote]           NVARCHAR(256) NULL ,
	--[ReasonDisapproved]      NVARCHAR(256) NULL ,
	[IsInvoiced]             BIT NOT NULL DEFAULT(0),
	[DateInvoiced]           DATETIME NULL ,
	[DeliveryCity]           NVARCHAR(64) NULL ,
	[DeliveryState]          NVARCHAR(64) NULL ,
	[DeliveryZipCode]        NVARCHAR(6) NULL ,
	[DeliveryStreet]         NVARCHAR(128) NULL ,
	[DeliveryNumberLine1]    NVARCHAR(16) NULL ,
	[DeliveryNumberLine2]    NVARCHAR(16) NULL,
	
	[DateCreated]            DATETIME NOT NULL DEFAULT GETDATE(),
	[LastUpdated]            DATETIME NULL 

	,CONSTRAINT [PK_tblOrder] PRIMARY KEY CLUSTERED ([OrderID] ASC)
	,CONSTRAINT [UQ_tblOrder_OrderNr] UNIQUE ([OrderNr])
);
GO

CREATE TRIGGER [dbo].[trgOrder] ON [dbo].[tblOrder]
AFTER UPDATE

AS

BEGIN
	SET	NOCOUNT ON

    UPDATE	X
    SET
         LastUpdated = GETDATE()
		--,ModUser = SYSTEM_USER
	FROM [dbo].[tblOrder] X
	INNER JOIN inserted I
		ON	I.[OrderID] = X.[OrderID]
END
GO