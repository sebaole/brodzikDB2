CREATE TABLE [dbo].[tblOrder]
(
	[OrderID]                INT IDENTITY (1, 1) NOT NULL ,
	[UserID]                 INT NOT NULL ,
	[OrderNr]                NVARCHAR(16) NOT NULL , -- UQ INDEX !!!!!
	[OrderDate]              DATETIME NOT NULL  DEFAULT GETDATE(),
	[DeliveryDate]           DATETIME NOT NULL ,
	[IsSelfPickup]           BIT NOT NULL ,
	[TotalPrice]             MONEY NOT NULL ,
	[TotalPriceWithDiscount] MONEY NOT NULL ,
	[CustomerNote]           NVARCHAR(256) NULL ,
	[ReasonDisapproved]      NVARCHAR(256) NULL ,
	[IsInvoiced]             BIT NULL ,
	[DateInvoiced]           DATETIME NULL ,
	[DeliveryCity]           NVARCHAR(64) NULL ,
	[DeliveryState]          NVARCHAR(64) NULL ,
	[DeliveryZipCode]        NVARCHAR(6) NULL ,
	[DeliveryStreet]         NVARCHAR(128) NULL ,
	[DeliveryNumberLine1]    NVARCHAR(16) NULL ,
	[DeliveryNumberLine2]    NVARCHAR(16) NULL ,
	
	CONSTRAINT [PK_tblOrder] PRIMARY KEY CLUSTERED ([OrderID] ASC)
);
GO