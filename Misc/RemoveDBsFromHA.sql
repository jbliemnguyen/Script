DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @haGrp VARCHAR(50) -- HA group name  
DECLARE @cmd NVARCHAR(256) -- cmd  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = 'L:\Backup\'  
 
-- HA group name
SET @haGrp = 'ROBDEV-SQL-HA'

-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb','ReportServer','ReportServerTempDB')  -- exclude these databases
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
      -- Remove from HA group first.
	  if exists(select * from sys.availability_databases_cluster where database_name  = @name)
	  begin
		set @cmd = 'ALTER AVAILABILITY GROUP [' + @haGrp + '] REMOVE DATABASE ' + @name
		exec sp_executesql @cmd
	  end
	  -- Set recovery mode to simple.
	  set @cmd = 'ALTER DATABASE ' + @name + ' SET RECOVERY SIMPLE'
	  exec sp_executesql @cmd
	  -- Shrink the log file to 1MB.
	  set @cmd = 'USE ' + @name + '; DBCC SHRINKFILE (' + @name + '_Log, 1)'
	  exec sp_executesql @cmd
	  -- Drop replica.
	  if exists(select * from [ROBDEV-SQL2].[Master].sys.databases where name = @name)
	  begin
		set @cmd = 'ALTER DATABASE ' + @name + ' SET HADR OFF'
		exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
		set @cmd = 'DROP DATABASE ' + @name
		exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
      end
	  -- Next database...
      FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor