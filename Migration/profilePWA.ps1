##################################
# Migration Profile for PWA

# Src SQL Servers
$Global:Src2013_SQLServer = "FDC1S-SPSQLPR1";

# Dest SQL Servers
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLT1";

# Backup Locations (Share needs more space).
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://test.sp.ferc.gov";

# Consolidation settings
$Global:Consolidation_Port = 86;
$Global:Consolidation_WebApp = "http://$($env:COMPUTERNAME)";

# Databases
$Global:2013_Databases = @(
'WSS_CONTENT', 'PROJECTWEBAPP');

# Database Mappings
$Global:DatabaseMappings = @{`
'WSS_CONTENT'='FERC_Content_PWA'; 
'PROJECTWEBAPP'='FERC_PWA_Instance';
};

# Mount these databases differently.
$Global:PWADatabases = @('FERC_PWA_Instance');

# Managed Paths
$Global:ExplicitManagedPaths = @();

# Known Dead Sites
$Global:DeadSites = @("$($Global:Consolidation_WebApp):$($Global:Consolidation_Port)/");
