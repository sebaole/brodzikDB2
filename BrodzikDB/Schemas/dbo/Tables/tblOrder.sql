CREATE TABLE [dbo].[tblOrder]
(
	[OrderID]                INT IDENTITY (1, 1) NOT NULL ,
	[UserID]                 INT NOT NULL ,
	[OrderNr]                NVARCHAR(16) NOT NULL ,
	[OrderDate]              DATETIME NOT NULL  DEFAULT GETDATE(),
	[DeliveryDate]           DATETIME NOT NULL ,
	[IsSelfPickup]           BIT NOT NULL ,
	[CustomerNote]           NVARCHAR(256) NULL ,
	[IsInvoiced]             BIT NOT NULL DEFAULT(0),
	[DateInvoiced]           DATETIME NULL ,
	[DeliveryCity]           NVARCHAR(64) NULL ,
	[DeliveryState]          NVARCHAR(64) NULL ,
	[DeliveryZipCode]        NVARCHAR(6) NULL ,
	[DeliveryStreet]         NVARCHAR(128) NULL ,
	[DeliveryNumberLine1]    NVARCHAR(16) NULL ,
	[DeliveryNumberLine2]    NVARCHAR(16) NULL,
	[ContactPersonFirstName] NVARCHAR(150) NULL ,
	[ContactPersonLastName]  NVARCHAR(150) NULL ,
	[ContactPhoneNumber]     NVARCHAR(32) NULL ,	
	[IsRecurring]			 BIT NOT NULL DEFAULT(0),
	[RecurrenceWeekNumber]	 TINYINT NULL,
	[DateEndRecurrence]		 DATETIME NULL,
	[RecurrenceBaseOrderID]	 INT NULL,

	[DateCreated]            DATETIME NOT NULL DEFAULT GETDATE(),
	[LastUpdated]            DATETIME NULL 

	,CONSTRAINT [PK_tblOrder] PRIMARY KEY CLUSTERED ([OrderID] ASC)
	,CONSTRAINT [UQ_tblOrder_OrderNr] UNIQUE ([OrderNr])
	,CONSTRAINT [CK_tblOrder_OrderDate_DeliveryDate] CHECK ([DeliveryDate] > [OrderDate])
	--,CONSTRAINT [UQ_tblOrder_RecurrenceBaseOrderID_DeliveryDate] UNIQUE ([RecurrenceBaseOrderID], [DeliveryDate]) -- safe check for no chance to insert recurring order > 1x
);
GO

CREATE UNIQUE INDEX UQ_IX_tblOrder_RecurrenceBaseOrderID_DeliveryDate ON [dbo].[tblOrder]([RecurrenceBaseOrderID], [DeliveryDate]) WHERE [RecurrenceBaseOrderID] IS NOT NULL
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