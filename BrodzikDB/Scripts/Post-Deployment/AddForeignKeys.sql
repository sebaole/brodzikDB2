
ALTER TABLE [dbo].[tblAddress] WITH CHECK ADD CONSTRAINT [FK1_tblAddress_UserID_tblUser_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblAddress] CHECK CONSTRAINT [FK1_tblAddress_UserID_tblUser_UserID]
GO

ALTER TABLE [dbo].[tblOrder] WITH CHECK ADD CONSTRAINT [FK1_tblOrder_UserID_tblUser_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblOrder] CHECK CONSTRAINT [FK1_tblOrder_UserID_tblUser_UserID]
GO

ALTER TABLE [dbo].[tblOrder] WITH CHECK ADD CONSTRAINT [FK2_tblOrder_RecurrenceBaseOrderID_tblOrder_OrderID] FOREIGN KEY ([RecurrenceBaseOrderID]) REFERENCES [dbo].[tblOrder]([OrderID])
GO
ALTER TABLE [dbo].[tblOrder] CHECK CONSTRAINT [FK2_tblOrder_RecurrenceBaseOrderID_tblOrder_OrderID]
GO

ALTER TABLE [dbo].[tblOrderHistory] WITH CHECK ADD CONSTRAINT [FK1_tblOrderHistory_OrderStatusID_tblOrderStatus_OrderStatusID] FOREIGN KEY ([OrderStatusID]) REFERENCES [dict].[tblOrderStatus]([OrderStatusID])
GO
ALTER TABLE [dbo].[tblOrderHistory] CHECK CONSTRAINT [FK1_tblOrderHistory_OrderStatusID_tblOrderStatus_OrderStatusID]
GO

ALTER TABLE [dbo].[tblOrderHistory] WITH CHECK ADD CONSTRAINT [FK2_tblOrderHistory_OrderID_tblOrder_OrderID] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[tblOrder]([OrderID])
GO
ALTER TABLE [dbo].[tblOrderHistory] CHECK CONSTRAINT [FK2_tblOrderHistory_OrderID_tblOrder_OrderID]
GO

ALTER TABLE [dbo].[tblOrderItem] WITH CHECK ADD CONSTRAINT [FK1_tblOrderItem_OrderID_tblOrder_OrderID] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[tblOrder]([OrderID])
GO
ALTER TABLE [dbo].[tblOrderItem] CHECK CONSTRAINT [FK1_tblOrderItem_OrderID_tblOrder_OrderID]
GO

ALTER TABLE [dbo].[tblOrderItem] WITH CHECK ADD CONSTRAINT [FK2_tblOrderItem_ProductID_tblProduct_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProduct]([ProductID])
GO
ALTER TABLE [dbo].[tblOrderItem] CHECK CONSTRAINT [FK2_tblOrderItem_ProductID_tblProduct_ProductID]
GO

ALTER TABLE [dbo].[tblOrderNotification] WITH CHECK ADD CONSTRAINT [FK1_tblOrderNotification_OrderHistoryID_tblOrderHistory_OrderHistoryID] FOREIGN KEY ([OrderHistoryID]) REFERENCES [dbo].[tblOrderHistory]([OrderHistoryID])
GO
ALTER TABLE [dbo].[tblOrderNotification] CHECK CONSTRAINT [FK1_tblOrderNotification_OrderHistoryID_tblOrderHistory_OrderHistoryID]
GO

ALTER TABLE [dbo].[tblProduct] WITH CHECK ADD CONSTRAINT [FK1_tblProduct_CategoryID_tblProductCategory_CategoryID] FOREIGN KEY ([CategoryID]) REFERENCES [dict].[tblProductCategory]([CategoryID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK1_tblProduct_CategoryID_tblProductCategory_CategoryID]
GO

ALTER TABLE [dbo].[tblProduct] WITH CHECK ADD CONSTRAINT [FK1_tblProduct_VATID_tblVATRate_VATID] FOREIGN KEY ([VATID]) REFERENCES [dict].[tblVATRate]([VATID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK1_tblProduct_VATID_tblVATRate_VATID]
GO

ALTER TABLE [dbo].[tblShoppingCart] WITH CHECK ADD CONSTRAINT [FK1_tblShoppingCart_UserID_tblUser_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblShoppingCart] CHECK CONSTRAINT [FK1_tblShoppingCart_UserID_tblUser_UserID]
GO

ALTER TABLE [dbo].[tblShoppingCart] WITH CHECK ADD CONSTRAINT [FK2_tblShoppingCart_ProductID_tblProduct_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[tblProduct]([ProductID])
GO
ALTER TABLE [dbo].[tblShoppingCart] CHECK CONSTRAINT [FK2_tblShoppingCart_ProductID_tblProduct_ProductID]
GO

ALTER TABLE [dbo].[tblUser] WITH CHECK ADD CONSTRAINT [FK1_tblUser_UserRoleID_tblUserRole_UserRoleID] FOREIGN KEY ([UserRoleID]) REFERENCES [dict].[tblUserRole]([UserRoleID])
GO
ALTER TABLE [dbo].[tblUser] CHECK CONSTRAINT [FK1_tblUser_UserRoleID_tblUserRole_UserRoleID]
GO

ALTER TABLE [dbo].[tblUserNotification] WITH CHECK ADD CONSTRAINT [FK1_tblUserNotification_UserID_tblUser_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tblUser]([UserID])
GO
ALTER TABLE [dbo].[tblUserNotification] CHECK CONSTRAINT [FK1_tblUserNotification_UserID_tblUser_UserID]
GO