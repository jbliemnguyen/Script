#############################################################
# SharePoint Settings
# Rob Garrett
# PRODUCTION SERVERS

# Servers
$caServer = "FDC1S-SP23APPP1";
$wfeServers = ("FDC1S-SP23WFEP1", "FDC1S-SP23WFEP2");
$appServers = ("FDC1S-SP23APPP1", "FDC1S-SP23APPP2");
$crawlServers = ("FDC1S-SP23APPP3", "FDC1S-SP23APPP4");
$queryServers = ("FDC1S-SP23APPP1", "FDC1S-SP23APPP2");

# SP
$spVer = "15";
$CAportNumber = "2013";
$passphrase = "Sharepoint03";

# Accounts
$domain = "ADFERC";
$spFarmAcctName = "$domain\svc.spfarm.prod";
$spAdminAcctName = "$domain\svc.spadmin.prod";
$spServiceAcctName = "$domain\svc.spservice.prod";
$spc2WTSAcctName = "$domain\svc.spservice.prod";
$spSearchCrawlAcctName = "$domain\svc.spsearch.prod";
$spAppPoolAcctName = "$domain\svc.spapppool.prod";
$spSuperUserAcctName = "$domain\svc.spCacheSuperUser.prod";
$spSuperReaderAcctName = "$domain\svc.spCacheSuperReader.prod";
$spUPSAcctName = "$domain\svc.spfarm.prod";

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
$dbPrefix = "SPPROD";
$dbServer = "SPSQL"; # Alias used for all SQL connections.
$dbPhysicalServer = "FDC1S-SP23SQLP1";
$sqlServerPool = ("FDC1S-SP23SQLP1");

# DNS
$lbPortalName = "sharepoint.ferc.gov";
$lbMySiteHostName = "sharepoint-my.ferc.gov";

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
$appDomain = "spapps.ferc.gov";

#PWA
$pwaWebAppUrl = "http://projects.ferc.gov";
$pwaWebAppHostHeader = "projects.ferc.gov";

#S2S
$appsPFX = "E:\Certs\spapps.cer";
$s2sSiteUrlHttp = "http://sharepoint.ferc.gov";
$s2sSiteUrlHttps = "https://sharepoint.ferc.gov";
