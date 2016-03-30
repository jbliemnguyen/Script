##################################
# Migration Profile for CFO

# Src SQL Servers
$Global:Src2010_SQLServer = "F052654-P-W\SharePoint";
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations
$Global:SCBackupLocation = "E:\SiteCollectionBackup";
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2010_Port = 84;
$Global:2010_WebApp = "http://$($env:COMPUTERNAME)";
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Databases
$Global:2010_Databases = @('SP_OED_DCFO_CONTENT');

# Mappings (2007-2010/2013).
$Global:DatabaseMappings = @{`
'SP_OED_DCFO_CONTENT'='FERC_Content_CFO';
};

# Managed Paths
$Global:ExplicitManagedPaths = @('oed/dcfo');
$Global:WildcardManagedPaths = @();

