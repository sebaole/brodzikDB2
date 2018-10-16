-- ************************************** [dbo].[tblProductDiscount]

CREATE TABLE [dbo].[tblProductDiscount]
(
 [DateFrom]          DATETIME NOT NULL ,
 [ProductDiscountID] INT IDENTITY (1, 1) NOT NULL ,
 [DateTo]            DATETIME NOT NULL ,
 [Rate]              DECIMAL(5,4) NOT NULL ,
 [DateCreated]       DATETIME NOT NULL  DEFAULT GETDATE(),
 [LastUpdated]       DATETIME NULL ,
 [ProductID]         INT NOT NULL ,

 CONSTRAINT [PK_tblProductDiscount] PRIMARY KEY CLUSTERED ([ProductDiscountID] ASC)
);
GO