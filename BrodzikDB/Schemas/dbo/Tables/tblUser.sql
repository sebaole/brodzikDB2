CREATE TABLE [dbo].[tblUser]
(
	 [UserID]					INT IDENTITY (1,1) NOT NULL 
	,[UserRoleID]				TINYINT NOT NULL 
	,[LoginName]				NCHAR(9) NOT NULL 
	,[PasswordHash]				NVARCHAR(128) NOT NULL 
	,[PasswordSalt]				NVARCHAR(128) NOT NULL 
	,[PhoneNumber]				NCHAR(9) NOT NULL 
	,[Email]					NVARCHAR(256) NULL 
	,[FirstName]				NVARCHAR(150) NULL 
	,[LastName]					NVARCHAR(150) NULL 
	,[IsBusinessClient]			BIT NOT NULL 
	,[CompanyName]				NVARCHAR(256) NULL 
	,[NIP]						NCHAR(10) NULL 
	,[IsWholesalePriceActive]	BIT NOT NULL DEFAULT(0)
	,[IsDeliveryActive]			BIT NOT NULL DEFAULT(0)
	,[IsGDPRAccepted]			BIT NOT NULL DEFAULT(0)
	,[IsMarketingAccepted]		BIT NOT NULL DEFAULT(0)
	,[IsActive]					BIT NOT NULL DEFAULT(1)
	,[DateCreated]				DATETIME NOT NULL  DEFAULT GETDATE()
	,[LastUpdated]				DATETIME NULL 
	,CONSTRAINT [PK_tblUserLogin] PRIMARY KEY CLUSTERED ([UserID] ASC)
	,CONSTRAINT [UQ_tblUser_LoginName] UNIQUE ([LoginName])
	
);
GO

CREATE TRIGGER [dbo].[trgUser] ON [dbo].[tblUser]
AFTER UPDATE

AS

BEGIN
	SET	NOCOUNT ON

    UPDATE	X
    SET
         LastUpdated = GETDATE()
		--,ModUser = SYSTEM_USER
	FROM [dbo].[tblUser] X
	INNER JOIN inserted I
		ON	I.[UserID] = X.[UserID]
END
GO