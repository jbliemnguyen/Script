#############################################################
# SharePoint Settings
# Rob Garrett
# TEST SERVERS

# Servers
$caServer = "FDC1S-SP23APPT1";
$wfeServers = ("FDC1S-SP23WFET1", "FDC1S-SP23WFET2");
$appServers = ("FDC1S-SP23APPT1", "FDC1S-SP23APPT2");
$crawlServers = ("FDC1S-SP23APPT3", "FDC1S-SP23APPT4");
$queryServers = ("FDC1S-SP23APPT1", "FDC1S-SP23APPT2");

# SP
$spVer = "15";
$CAportNumber = "2013";
$passphrase = "Sharepoint03";

# Accounts
$domain = "ADFERC";
$spFarmAcctName = "$domain\svc.spfarm.test";
$spAdminAcctName = "$domain\svc.spadmin.test";
$spServiceAcctName = "$domain\svc.spservice.test";
$spc2WTSAcctName = "$domain\svc.spservice.test";
$spSearchCrawlAcctName = "$domain\svc.spsearch.test";
$spAppPoolAcctName = "$domain\svc.spapppool.test";
$spSuperUserAcctName = "$domain\svc.spCacheSuperUser.test";
$spSuperReaderAcctName = "$domain\svc.spCacheSuperReader.test";
$spUPSAcctName = "$domain\svc.spfarm.test";

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
$dbPrefix = "SPTEST";
$dbServer = "SPSQL"; # Alias used for all SQL connections.
$dbPhysicalServer = "FDC1S-SP23SQLT1";
$sqlServerPool = ("FDC1S-SP23SQLT1");

# DNS
$lbPortalName = "sharepoint-test.ferc.gov";
$lbMySiteHostName = "sharepoint-test-my.ferc.gov";

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
$pwaWebAppUrl = "http://projects-test.ferc.gov";
$pwaWebAppHostHeader = "projects-test.ferc.gov";

#S2S
$appsPFX = "E:\Certs\spapps-test.cer";
$s2sSiteUrlHttp = "http://sharepoint-test.ferc.gov";
$s2sSiteUrlHttps = "https://sharepoint-test.ferc.gov";
