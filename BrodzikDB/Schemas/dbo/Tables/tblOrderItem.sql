CREATE TABLE [dbo].[tblOrderItem]
(
	[OrderItemID]         INT IDENTITY (1, 1) NOT NULL ,
	[OrderID]             INT NOT NULL ,
	[ProductID]           INT NOT NULL ,
	[ProductName]         NVARCHAR(128) NOT NULL ,
	[Quantity]            TINYINT NOT NULL ,
	[UnitPrice]           MONEY NOT NULL ,
	[VATRate]             DECIMAL(5,4) NOT NULL ,
	[UserDiscountRate]    DECIMAL(5,4) NULL ,
	[ProductDiscountRate] DECIMAL(5,4) NULL ,
	
	CONSTRAINT [PK_tblOrderItem] PRIMARY KEY CLUSTERED ([OrderItemID] ASC)
);
GO