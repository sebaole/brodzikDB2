CREATE TABLE [dbo].[tblOrderHistory]
(
	[OrderID]				INT NOT NULL ,
	[OrderHistoryID]		INT IDENTITY (1, 1) NOT NULL ,
	[OrderStatusID]			TINYINT NOT NULL ,
	[DateCreated]			DATETIME NOT NULL  DEFAULT GETDATE(),
	[ReasonDisapproved]     NVARCHAR(256) NULL ,
	CONSTRAINT [PK_tblOrderHistory] PRIMARY KEY CLUSTERED ([OrderHistoryID] ASC)
);
GO