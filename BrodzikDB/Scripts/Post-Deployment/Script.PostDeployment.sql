/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


PRINT N'--------------------------------------------------------------'
PRINT N'PostDeployment'
PRINT N'--------------------------------------------------------------'

GO

PRINT N'Start DropForeignKeys.sql'
:r .\DropForeignKeys.sql

PRINT N'Start PopulateDictTables.sql'
:r .\PopulateDictTables.sql

PRINT N'Start AddForeignKeys.sql'
:r .\AddForeignKeys.sql

GO