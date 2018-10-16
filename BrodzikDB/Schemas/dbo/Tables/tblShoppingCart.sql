-- ************************************** [dbo].[tblShoppingCart]

CREATE TABLE [dbo].[tblShoppingCart]
(
 [ShoppingCartID] INT IDENTITY (1, 1) NOT NULL ,
 [UserID]         INT NOT NULL ,
 [ProductID]      INT NOT NULL ,
 [Quantity]       TINYINT NOT NULL ,
 [DateCreated]    DATETIME NOT NULL  DEFAULT GETDATE(),

 CONSTRAINT [PK_tblShoppingCart] PRIMARY KEY CLUSTERED ([ShoppingCartID] ASC)
);
GO