#############################################################
# SharePoint Settings
# Rob Garrett

# Servers
$caServer = "FDC1S-SP23WFED1";
$wfeServers = ("FDC1S-SP23WFED1");
$appServers = ("FDC1S-SP23WFED1");
$crawlServers = ("FDC1S-SP23WFED1");
$queryServers = ("FDC1S-SP23WFED1");

# SP
$spVer = "15";
$CAportNumber = "2013";
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
$dbPrefix = "WFED1";
$dbServer = "SPSQL"; # Alias used for all SQL connections.
$dbPhysicalServer = "FDC1S-SP23WFED1";
$sqlServerPool = ("FDC1S-SP23WFED1");

# DNS
$lbPortalName = "fdc1s-sp23wfed1";
$lbMySiteHostName = "fdc1s-sp23wfed1";

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
$appDomain = "fdc1s-sp23appd1.ferc.gov";

#PWA
$pwaWebAppUrl = "http://projects-d1.ferc.gov";
$pwaWebAppHostHeader = "projects-d1.ferc.gov";

#S2S
$appsPFX = "E:\Certs\fdc1s-sp23appd1.cer";
$s2sSiteUrlHttp = "http://$($lbPortalName).ferc.gov";
$s2sSiteUrlHttps = "https://$($lbPortalName).ferc.gov";
