-- ************************************** [dbo].[tblUserDiscount]

CREATE TABLE [dbo].[tblUserDiscount]
(
 [UserDiscountID] INT IDENTITY (1, 1) NOT NULL ,
 [DateFrom]       DATETIME NOT NULL ,
 [DateTo]         DATETIME NOT NULL ,
 [Rate]           DECIMAL(5,4) NOT NULL ,
 [DateCreated]    DATETIME NOT NULL  DEFAULT GETDATE(),
 [LastUpdated]    DATETIME NULL ,
 [UserID]         INT NOT NULL ,

 CONSTRAINT [PK_tblClientDiscount] PRIMARY KEY CLUSTERED ([UserDiscountID] ASC)
);
GO