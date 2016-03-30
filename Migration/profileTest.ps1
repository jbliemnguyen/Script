##################################
# Migration Profile for Test

# Src SQL Servers
$Global:Src2007_SQLServer = "FDC1S-SPDBP1";
$Global:Src2010_SQLServer = "FDC1S-SP23SQLT1";
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
$Global:Dest2010_SQLServer = "FDC1S-SP23SQLT1";
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations
$Global:SCBackupLocation = "E:\SiteCollectionBackup";
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2010_Port = 83;
$Global:2010_WebApp = "http://$($env:COMPUTERNAME)";
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Consolidation settings
$Global:Consolidation_Port = 83;
$Global:Consolidation_WebApp = "http://$($env:COMPUTERNAME)";

# Databases
$Global:2007_Databases = @('WSS_Content_OED');
$Global:2010_Databases = @('FERC_Content_TestMigration2010');
$Global:2013_Databases = @('FERC_Content_TestMigration');

# Mappings (2007-2010/2013).
$Global:DatabaseMappings2013 = @{`
'FERC_Content_TestMigration2010'='FERC_Content_TestMigration'; };
$Global:DatabaseMappings2010 = @{`
'WSS_Content_OED'='FERC_Content_TestMigration2010'; };
$Global:DatabaseMappings = @{`
'WSS_Content_OED'='FERC_Content_TestMigration'};

# Managed Paths
$Global:ExplicitManagedPaths = @('/sites/testMigration/cpic','/sites/testMigration/oed');
$Global:WildcardManagedPaths = @();

# Site Collection Mappings
$Global:SiteCollectionMappings = @{ `
'/cpic'='/sites/testMigration/cpic'; `
'/oed'='/sites/testMigration/oed'; };

