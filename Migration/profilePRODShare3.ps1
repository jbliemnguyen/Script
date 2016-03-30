##################################
# Migration Profile for Production

# Src SQL Servers
$Global:Src2013_SQLServer = "FDC1S-SP23SQLT1";

# Dest SQL Servers
$Global:Dest2013_SQLServer = "FDC1S-SP23SQLP1";

# Backup Locations
$Global:BackupLocation = "\\fdc1s-sp23sqlt1\sqlbackup\";

# WebApp and Ports
$Global:2013_Port = 443;
$Global:2013_WebApp = "https://sp.ferc.gov";

# Databases

$Global:2013_Databases = @('FERC_Content_Share3_ProgramOffices');

# Managed Paths
$Global:ExplicitManagedPaths = @(
);
