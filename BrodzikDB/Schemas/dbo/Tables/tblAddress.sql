CREATE TABLE [dbo].[tblAddress]
(
	[AddressID]              INT IDENTITY (1, 1) NOT NULL ,
	[UserID]                 INT NOT NULL ,
	[Street]                 NVARCHAR(128) NOT NULL ,
	[NumberLine1]            NVARCHAR(16) NOT NULL ,
	[NumberLine2]            NVARCHAR(16) NULL ,
	[City]                   NVARCHAR(64) NOT NULL ,
	[State]                  NVARCHAR(64) NOT NULL ,
	[ZipCode]                NCHAR(6) NOT NULL ,
	[ContactPersonFirstName] NVARCHAR(150) NULL ,
	[ContactPersonLastName]  NVARCHAR(150) NULL ,
	[ContactPhoneNumber]     NVARCHAR(32) NULL ,
	[IsMainAddress]          BIT NOT NULL ,
	[DateCreated]            DATETIME NOT NULL DEFAULT GETDATE(),
	[LastUpdated]            DATETIME NULL ,
	CONSTRAINT [PK_tblDeliveryAddress] PRIMARY KEY CLUSTERED ([AddressID] ASC)
);
GO

CREATE TRIGGER [dbo].[trgAddress] ON [dbo].[tblAddress]
AFTER UPDATE

AS

BEGIN
	SET	NOCOUNT ON

    UPDATE	X
    SET
         LastUpdated = GETDATE()
		--,ModUser = SYSTEM_USER
	FROM [dbo].[tblAddress] X
	INNER JOIN inserted I
		ON	I.[AddressID] = X.[AddressID]
END
GO