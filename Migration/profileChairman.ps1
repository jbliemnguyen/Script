##################################
# Migration Profile for Chairman

# Src SQL Servers
$Global:Src2007_SQLServer = "WDCSPSQLPS02";
$Global:Src2010_SQLServer = "FDC1S-SP23SQLD1\SharePointInt";
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
$Global:Dest2010_SQLServer = "FDC1S-SP23SQLD1\SharePointInt";
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations
$Global:SCBackupLocation = "E:\SiteCollectionBackup";
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2010_Port = 83;
$Global:2010_WebApp = "http://$($env:COMPUTERNAME)";
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Databases
$Global:2007_Databases = @('WSS_Content_Offices', 'WSS_Content');
$Global:2010_Databases = @('FERC_Content_Chairman_Offices', 'FERC_Content_Chairman');

# Mappings (2007-2010/2013).
$Global:DatabaseMappings = @{`
'WSS_Content_Offices'='FERC_Content_Chairman_Offices'; `
'WSS_Content'='FERC_Content_Chairman'; };

# Managed Paths
$Global:ExplicitManagedPaths = @('chairman','chairman/office/oea');
$Global:WildcardManagedPaths = @();

# Site Collection Mappings
$Global:SiteCollectionMappings = @{ `
'/'='/chairman'; `
'/office/oea'='/chairman/office/oea' };