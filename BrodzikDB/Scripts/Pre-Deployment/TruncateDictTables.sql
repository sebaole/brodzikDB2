DECLARE @TruncateSQL AS NVARCHAR(MAX)

SET @TruncateSQL = (
					SELECT 'DELETE FROM ' + QUOTENAME(SS.name) + '.' + QUOTENAME(ST.name) + '; '
					FROM sys.tables ST
					INNER JOIN sys.schemas SS
						ON ST.SCHEMA_ID = SS.SCHEMA_ID
					WHERE SS.name = 'dict'
					FOR XML PATH('')
					);

EXEC (@TruncateSQL);