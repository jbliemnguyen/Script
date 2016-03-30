#####################################
# Migration Profile for Commissioners

# Src SQL Servers
$Global:Src2010_SQLServer = "F052651-P-W";
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations
$Global:SCBackupLocation = "E:\SiteCollectionBackup";
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2010_Port = 85;
$Global:2010_WebApp = "http://$($env:COMPUTERNAME)";
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Databases
$Global:2007_Databases = @('WSS_CONTENT_COMMISSIONERCLARK', 'WSS_CONTENT_CLARK2', 'WSS_CONTENT_MOELLER', 'WSS_CONTENT_NORRIS1');
$Global:2010_Databases = @('FERC_Content_Comms_Clark', 'FERC_Content_Comms_LaFluer', 'FERC_Content_Comms_Moeller', 'FERC_Content_Comms_MoellerOffice');

# Mappings (2007-2010/2013).
$Global:DatabaseMappings = @{`
'WSS_CONTENT_COMMISSIONERCLARK'='FERC_Content_Comms_Clark'; `
'WSS_CONTENT_CLARK2'='FERC_Content_Comms_LaFluer'; `
'WSS_CONTENT_MOELLER'='FERC_Content_Comms_Moeller'; `
'WSS_CONTENT_NORRIS1'='FERC_Content_Comms_MoellerOffice';};

# Managed Paths
$Global:ExplicitManagedPaths = @('sites/Commissionerclark', 'sites/CommissionerLaFleur', 'sites/CommissionerMoeller', 'sites/CommissionerMoelleroffice');
$Global:WildcardManagedPaths = @();

# Site Collection Mappings
$Global:SiteCollectionMappings = @{ `
'/sites/Commissionerclark'='/sites/Commissionerclark'; `
'/sites/CommissionerLaFleur'='/sites/CommissionerLaFleur'; `
'/sites/CommissionerMoeller'='/sites/CommissionerMoeller'; `
'/sites/CommissionerMoelleroffice'='/sites/CommissionerMoelleroffice';
 };


