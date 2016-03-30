#############################################################
# SharePoint Settings
# Rob Garrett

# Servers
$caServer = "FDC1S-SP23WFED4";
$wfeServers = ("FDC1S-SP23WFED4");
$appServers = ("FDC1S-SP23WFED4");
$crawlServers = ("FDC1S-SP23WFED4");
$queryServers = ("FDC1S-SP23WFED4");

# SP
$spVer = "14";
$CAportNumber = "2010";
$passphrase = "Sharepoint03";

# Accounts
$domain = "ADFERC";
$spFarmAcctName = "$domain\svc.spfarm.dev";
$spAdminAcctName = "$domain\svc.spadmin.dev";
$spServiceAcctName = "$domain\svc.spservice.dev";
$spc2WTSAcctName = "$domain\svc.spservice.dev";
$spSearchCrawlAcctName = "$domain\svc.spsearch.dev";
$spAppPoolAcctName = "$domain\svc.spapppool.dev";
$spSuperUserAcctName = "$domain\svc.spCacheSuperUser.dev";
$spSuperReaderAcctName = "$domain\svc.spCacheSuperReader.dev";
$spUPSAcctName = "$domain\svc.spfarm.dev";

# Passwords
$spFarmAcctPwd = "Sharepoint03";
$spAdminAcctPwd = $spFarmAcctPwd;
$spServiceAcctPwd = $spFarmAcctPwd;
$spc2WTSAcctPwd = $spFarmAcctPwd;
$spSearchCrawlAcctPwd = $spFarmAcctPwd;
$spAppPoolAcctPwd = $spFarmAcctPwd;
$spSuperUserAcctPwd = $spFarmAcctPwd;
$spSuperReaderAcctPwd = $spFarmAcctPwd;
$spUPSAcctPwd = $spFarmAcctPwd;

# SQL
$dbPrefix = "WFEINT";
$dbServer = "SPSQL"; # Alias used for all SQL connections.
$dbPhysicalServer = "FDC1S-SP23SQLD1";
$sqlServerPool = ("FDC1S-SP23SQLD1");

# DNS
$lbPortalName = "FDC1S-SP23WFED4";
$lbMySiteHostName = "FDC1S-SP23WFED4";

# Logging
$logLocation =  "E:\SPLOGS";
$logSpaceUsage = 10; # in GB
$logDaysToKeepLogs = 14;
$logCutInterval = 30; # Minutes before new file created.

# Email
$smtpServer = "mailrelay.ferc.gov";
$fromEmailAddress = "sharepoint@ferc.gov";

# Search
$indexLocation = "E:\SPSearchIndexes";

# Other
$forceRemote = [bool]0;
$adminEmail = "sharepointteam@ferc.gov";

