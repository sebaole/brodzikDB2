INSERT INTO [dict].[tblUserRole]
(
	 [UserRoleID]
	,[UserRoleName]
	,[Description]
)
VALUES 	
	 (1		,'admin'		,null)
	,(2		,'client'		,null)

INSERT INTO [dict].[tblOrderStatus]
(
	 [OrderStatusID]
	,[StatusCode]         
	,[Description]        
	,[IsNotificationSMS]  
	,[IsNotificationEmail]
	,[SortOrder]
)
VALUES
	 (1		,'NEW'				,'Przyjęte do weryfikacji'	,1	,0	,1)
	,(2		,'INPROGRESS'		,'W trakcie realizacji'		,1	,0	,2)
	,(3		,'INDELIVERY'		,'W trakcie dostawy'		,1	,0	,3)
	,(4		,'READY2PICKUP'		,'Gotowe do odbioru'		,1	,0	,4)
	,(5		,'REJECTED'			,'Odrzucone'				,1	,0	,5)
	,(6		,'DONE'				,'Zrealizowane'				,1	,0	,6)


SET IDENTITY_INSERT [dict].[tblVATRate] ON
INSERT [dict].[tblVATRate] 
(
	[VATID], [VATRate], [IsActive]
) 
VALUES 
	 (1		, CAST(0.0000 AS DECIMAL(5, 4))		, 1)
	,(2		, CAST(0.0500 AS DECIMAL(5, 4))		, 1)
	,(3		, CAST(0.0800 AS DECIMAL(5, 4))		, 1)
	,(4		, CAST(0.2300 AS DECIMAL(5, 4))		, 1)
SET IDENTITY_INSERT [dict].[tblVATRate] OFF


SET IDENTITY_INSERT [dict].[tblProductCategory] ON 
INSERT [dict].[tblProductCategory] 
(
	[CategoryID], [CategoryName], [Description]
) 
VALUES 
	 (1		, N'Chleb'		, N'')
	,(2		, N'Pasta'		, N'')
	,(3		, N'Torba'		, N'')
	,(4		, N'Makaron'	, N'')
	,(5		, N'Kasza'		, N'')
SET IDENTITY_INSERT [dict].[tblProductCategory] OFF