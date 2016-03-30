##################################
# Migration Profile for Share3

# Src SQL Servers
$Global:Src2007_SQLServer = "FDC1S-SPDBP1";
#$Global:Src2010_SQLServer = "FDC1S-SP23SQLD1\SharePointInt";
$Global:Src2010_SQLServer = "FDC1S-SP23SQLT1";
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
#$Global:Dest2010_SQLServer = "FDC1S-SP23SQLD1\SharePointInt";
$Global:Dest2010_SQLServer = "FDC1S-SP23SQLT1";
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations
$Global:SCBackupLocation = "E:\SiteCollectionBackup";
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2010_Port = 82;
$Global:2010_WebApp = "http://$($env:COMPUTERNAME)";
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Consolidation settings
$Global:Consolidation_Port = 82;
$Global:Consolidation_WebApp = "http://$($env:COMPUTERNAME)";

# Databases
$Global:2007_Databases = @('SP_FERC_PO_Content');
$Global:2010_Databases = @('FERC_Content_Share3_ProgramOffices2010');
$Global:2013_Databases = @('FERC_Content_Share3_ProgramOffices');

# Mappings (2007-2010/2013).
$Global:DatabaseMappings2013 = @{`
'FERC_Content_Share3_ProgramOffices2010'='FERC_Content_Share3_ProgramOffices'; };
$Global:DatabaseMappings2010 = @{`
'SP_FERC_PO_Content'='FERC_Content_Share3_ProgramOffices2010'; };
$Global:DatabaseMappings = @{`
'SP_FERC_PO_Content'='FERC_Content_Share3_ProgramOffices'; `
'SP_Chairman_Content'='FERC_Content_Share3_Chairman'; `
'SP_COMMS_Content'='FERC_Content_Share3_Comms'; `
'WSS_Content_OALJ'='FERC_Content_Share3_OALJ'; `
'WSS_Content_OED'='FERC_Content_Share3_OEDCPIC'};

# Managed Paths
#$Global:ExplicitManagedPaths = @('cpic','oalj','oed','legacy/commissioners','legacy/chairman');
$Global:WildcardManagedPaths = @();

# Site Collection Mappings
$Global:SiteCollectionMappings = @{ `
'/cpic'='/cpic'; `
'/oalj'='/oalj'; `
'/oed'='/oed'; `
'/sites/chairman'='/legacy/chairman'; `
'/sites/commissioners'='/legacy/commissioners'; `
'/sites/ProgramOffices'='/sites/ProgramOffices' };

