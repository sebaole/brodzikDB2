DECLARE @DropFKSQL AS NVARCHAR(MAX)


SET @DropFKSQL =(				
				SELECT 
				'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) +
				' DROP CONSTRAINT ' + QUOTENAME(name)  + ';' 
				FROM sys.foreign_keys
				FOR XML PATH('')
				);

EXEC (@DropFKSQL);