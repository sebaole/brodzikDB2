/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

PRINT N'--------------------------------------------------------------'
PRINT N'PreDeployment'
PRINT N'--------------------------------------------------------------'

GO

PRINT N'Start DisableForeignKeys.sql'
:r .\DisableForeignKeys.sql

PRINT N'Start TruncateConfigTables.sql'
:r .\TruncateDictTables.sql

GO