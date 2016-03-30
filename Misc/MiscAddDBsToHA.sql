DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @haGrp VARCHAR(50) -- HA group name  
DECLARE @cmd NVARCHAR(256) -- cmd  
DECLARE @restore VARCHAR(256) -- path for restore files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = 'L:\Backup\'  
SET @restore = '\\ROBDEV-SQL\Backup\'
 
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
	  -- See if replica exists first
	  if db_id(@name) is not null 
	  begin
		-- Drop replica.
		set @cmd = 'ALTER DATABASE ' + @name + ' SET HADR OFF'
		exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
		set @cmd = 'DROP DATABASE ' + @name
		exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
	  end
	  -- Restore recovery mode to full.
	  set @cmd = 'ALTER DATABASE ' + @name + ' SET RECOVERY FULL'
	  exec sp_executesql @cmd
	  -- Perform full backup.
	  set @fileName = @path + @name + '.BAK'  
      BACKUP DATABASE @name TO DISK = @fileName WITH INIT
	  -- Backup logs only
	  set @fileName = @path + @name + '_Log.BAK'  
      BACKUP LOG @name TO DISK = @fileName WITH INIT, NOUNLOAD, NOFORMAT, SKIP, NOREWIND
	  -- Add back to HA group.
	  set @cmd = 'ALTER AVAILABILITY GROUP [' + @haGrp + '] ADD DATABASE ' + @name
	  exec sp_executesql @cmd
	  -- Restore replica from backup.
	  set @cmd = 'RESTORE DATABASE ' + @name + ' FROM DISK = ''' + @restore + @name + '.bak'' WITH NORECOVERY'
	  exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
	  -- Restore the log on replica.
	  set @cmd = 'RESTORE LOG ' + @name + ' FROM DISK = ''' + @restore + @name + '_Log.bak'' WITH FILE=1,NORECOVERY,NOUNLOAD'
	  exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
	  -- Join to availability group
	  set @cmd = 'ALTER DATABASE ' + @name + ' SET HADR AVAILABILITY GROUP = [' + @haGrp + ']'
	  exec [ROBDEV-SQL2].[master].dbo.sp_executesql @cmd
	  -- Next database...
      FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor