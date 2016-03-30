##################################
# Migration Profile for Share

# Src SQL Servers
$Global:Src2007_SQLServer = "WDCSPSQLPS01";
#$Global:Src2010_SQLServer = "FDC1S-SP23SQLD1\SharePointInt";
$Global:Src2010_SQLServer = "FDC1S-SP23SQLT1";
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
#$Global:Dest2010_SQLServer = "FDC1S-SP23SQLD1\SharePointInt";
$Global:Dest2010_SQLServer = "FDC1S-SP23SQLT1";
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations (Share needs more space).
$Global:SCBackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup";
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2010_Port = 81;
$Global:2010_WebApp = "http://$($env:COMPUTERNAME)";
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Consolidation settings
$Global:Consolidation_Port = 81;
$Global:Consolidation_WebApp = "http://$($env:COMPUTERNAME)";

# Databases
$Global:2007_Databases = @('FERCDCIO1_SITE');
$Global:2010_Databases = @('FERC_Content_Share2010');
$Global:2013_Databases = @('FERC_Content_Share');

# Mappings (2007-2010/2013).
$Global:DatabaseMappings2013 = @{`
'FERC_Content_Share2010'='FERC_Content_Share'; };
$Global:DatabaseMappings2010 = @{`
'FERCDCIO1_SITE'='FERC_Content_Share2010'; };
$Global:DatabaseMappings = @{`
'FERCDCIO1_SITE'='FERC_Content_Share'; };

# Managed Paths
$Global:ExplicitManagedPaths = @('teams','teams/ou/FERC','teams/ou/GD');
$Global:WildcardManagedPaths = @();

# Site Collection Mappings
$Global:SiteCollectionMappings = @{ `
'/'='/teams'; `
'/ou/FERC'='/teams/ou/FERC'; `
'/ou/GD'='/teams/ou/GD'; };

# Known Dead Sites
$Global:DeadWebs = @( `
"$($Global:Consolidation_WebApp):$($Global:Consolidation_Port)/SiteDirectory/DAMS/Projmain", `
"$($Global:Consolidation_WebApp):$($Global:Consolidation_Port)/SiteDirectory/eLibrary/projmain", `
"$($Global:Consolidation_WebApp):$($Global:Consolidation_Port)/SiteDirectory/spsow/projmain", `
"$($Global:Consolidation_WebApp):$($Global:Consolidation_Port)/SiteDirectory/wantest/test IT Sup");
