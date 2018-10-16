CREATE TABLE [dict].[tblUserRole]
(
	[UserRoleID]   TINYINT NOT NULL ,
	[UserRoleName] NVARCHAR(16) NOT NULL ,
	[Description]  NVARCHAR(128) NULL ,
	CONSTRAINT [PK_tblUserRole] PRIMARY KEY CLUSTERED ([UserRoleID] ASC)
);
GO