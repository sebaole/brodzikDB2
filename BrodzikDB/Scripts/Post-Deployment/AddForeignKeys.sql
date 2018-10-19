﻿
ALTER TABLE [dbo].[tblAddress] WITH CHECK ADD CONSTRAINT [FK_229] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblAddress] CHECK CONSTRAINT [FK_229]
GO

ALTER TABLE [dbo].[tblOrder] WITH CHECK ADD CONSTRAINT [FK_232] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblOrder] CHECK CONSTRAINT [FK_232]
GO

ALTER TABLE [dbo].[tblOrderHistory] WITH CHECK ADD CONSTRAINT [FK_180] FOREIGN KEY ([OrderStatusID]) REFERENCES [dict].[tblOrderStatus]([OrderStatusID])
GO
ALTER TABLE [dbo].[tblOrderHistory] CHECK CONSTRAINT [FK_180]
GO

ALTER TABLE [dbo].[tblOrderHistory] WITH CHECK ADD CONSTRAINT [FK_183] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[tblOrder]([OrderID])
GO
ALTER TABLE [dbo].[tblOrderHistory] CHECK CONSTRAINT [FK_183]
GO

ALTER TABLE [dbo].[tblOrderItem] WITH CHECK ADD CONSTRAINT [FK_151] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[tblOrder]([OrderID])
GO
ALTER TABLE [dbo].[tblOrderItem] CHECK CONSTRAINT [FK_151]
GO

ALTER TABLE [dbo].[tblOrderItem] WITH CHECK ADD CONSTRAINT [FK_154] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProduct]([ProductID])
GO
ALTER TABLE [dbo].[tblOrderItem] CHECK CONSTRAINT [FK_154]
GO

ALTER TABLE [dbo].[tblOrderNotification] WITH CHECK ADD CONSTRAINT [FK_196] FOREIGN KEY ([OrderHistoryID]) REFERENCES [dbo].[tblOrderHistory]([OrderHistoryID])
GO
ALTER TABLE [dbo].[tblOrderNotification] CHECK CONSTRAINT [FK_196]
GO

ALTER TABLE [dbo].[tblProduct] WITH CHECK ADD CONSTRAINT [FK_103] FOREIGN KEY ([CategoryID]) REFERENCES [dict].[tblProductCategory]([CategoryID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_103]
GO

ALTER TABLE [dbo].[tblProduct] WITH CHECK ADD CONSTRAINT [FK_109] FOREIGN KEY ([VATID]) REFERENCES [dict].[tblVATRate]([VATID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_109]
GO

ALTER TABLE [dbo].[tblProductDiscount] WITH CHECK ADD CONSTRAINT [FK_127] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProduct]([ProductID])
GO
ALTER TABLE [dbo].[tblProductDiscount] CHECK CONSTRAINT [FK_127]
GO

ALTER TABLE [dbo].[tblShoppingCart] WITH CHECK ADD CONSTRAINT [FK_262] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblShoppingCart] CHECK CONSTRAINT [FK_262]
GO

ALTER TABLE [dbo].[tblShoppingCart] WITH CHECK ADD CONSTRAINT [FK_265] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProduct]([ProductID])
GO
ALTER TABLE [dbo].[tblShoppingCart] CHECK CONSTRAINT [FK_265]
GO

ALTER TABLE [dbo].[tblUser] WITH CHECK ADD CONSTRAINT [FK_135] FOREIGN KEY ([UserRoleID]) REFERENCES [dict].[tblUserRole]([UserRoleID])
GO
ALTER TABLE [dbo].[tblUser] CHECK CONSTRAINT [FK_135]
GO

ALTER TABLE [dbo].[tblUserDiscount] WITH CHECK ADD CONSTRAINT [FK_235] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblUserDiscount] CHECK CONSTRAINT [FK_235]
GO

ALTER TABLE [dbo].[tblUserNotification] WITH CHECK ADD CONSTRAINT [FK_254] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblUserNotification] CHECK CONSTRAINT [FK_254]
GO

ALTER TABLE [log].[tblApplicationEventLog] WITH CHECK ADD CONSTRAINT [FK_273] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [log].[tblApplicationEventLog] CHECK CONSTRAINT [FK_273]
GO