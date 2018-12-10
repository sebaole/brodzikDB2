INSERT INTO [dict].[tblUserRole]
(
	 [UserRoleID]
	,[UserRoleName]
	,[Description]
)
VALUES 	
	 (1		,N'admin'		,null)
	,(2		,N'client'		,null)

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
	 (1		,N'NEW'				,N'Czekaj na potwierdzenie :-)'	,0	,0	,1)
	,(2		,N'INPROGRESS'		,N'Przyjęte'					,1	,0	,2)
	,(3		,N'INDELIVERY'		,N'W trakcie dostawy'			,0	,0	,3)
	,(4		,N'DONE'			,N'Odebrane :-)'				,0	,0	,5)
	,(5		,N'REJECTED'		,N'Odrzucone'					,1	,0	,6)
	,(6		,N'DELETED'			,N'Usunięte'					,1	,0	,7)
	--,(7		,N'RECURRING'		,N'Cykliczne'				,0	,0	,8)
	--,(8		,'READY2PICKUP'		,'Gotowe do odbioru'		,1	,0	,4)

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
	[CategoryID], [CategoryName], [Description], [IsKDRActive], [KDRGrossDiscount]
) 
VALUES 
	 (1		, N'Chleb'		, N'', 1	,2)
	,(2		, N'Pasta'		, N'', 1	,2)
	,(3		, N'Torba'		, N'', 0	,0)
	,(4		, N'Makaron'	, N'', 0	,0)
	,(5		, N'Kasza'		, N'', 0	,0)
SET IDENTITY_INSERT [dict].[tblProductCategory] OFF


SET IDENTITY_INSERT [dict].[tblCustomParam] ON 
GO
INSERT [dict].[tblCustomParam] 
(
	[IdParam], [ParamName], [ParamValue]
) 
VALUES 
	 (1	, N'AdresOdbioru'	, N'Warszawska 49, 05-120 Legionowo')
	,(2	, N'Godziny1'		, N'Pn - Pt: 7:30 - 19:00')
	,(3	, N'Godziny2'		, N'Sob: 9:00 - 14:00')
	,(4	, N'TelKontakt'		, N'782 126 785')
SET IDENTITY_INSERT [dict].[tblCustomParam] OFF
GO