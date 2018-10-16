DECLARE @DisableFKSQL AS NVARCHAR(MAX)


SET @DisableFKSQL =(				
				SELECT 
				'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) +
				' NOCHECK CONSTRAINT ' + QUOTENAME(name)  + ';' 
				FROM sys.foreign_keys
				FOR XML PATH('')
				);

EXEC (@DisableFKSQL);