#############################################################
# SharePoint Settings
# Rob Garrett

# Servers
$caServer = "ROBDEV-SP1";
$wfeServers = ("ROBDEV-SP1");
$appServers = ("ROBDEV-SP1");
$crawlServers = ("ROBDEV-SP1");
$queryServers = ("ROBDEV-SP1");

# SP
$spVer = "15";
$CAportNumber = "2013";
$passphrase = "Sharepoint03";

# Accounts
$domain = $env:USERDOMAIN;
$spFarmAcctName = "$domain\spfarm";
$spAdminAcctName = "$domain\spadmin";
$spServiceAcctName = "$domain\spservice";
$spc2WTSAcctName = "$domain\spc2wts";
$spSearchCrawlAcctName = "$domain\spsearch";
$spAppPoolAcctName = "$domain\spapppool";
$spSuperUserAcctName = "$domain\spCacheSuperUser";
$spSuperReaderAcctName = "$domain\spCacheSuperReader";
$spUPSAcctName = "$domain\spfarm";

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
$dbPrefix = "ROBDEV";
$dbServer = "SPSQL"; # Alias used for all SQL connections.
$dbPhysicalServer = "ROBDEV-SQL1";
$sqlServerPool = ("ROBDEV-SQL1");

# DNS
$lbPortalName = "ROBDEV-SP1";
$lbMySiteHostName = "ROBDEV-SP1";

# Logging
$logLocation =  "E:\SPLOGS";
$logSpaceUsage = 10; # in GB
$logDaysToKeepLogs = 14;
$logCutInterval = 30; # Minutes before new file created.

# Email
$smtpServer = "ROBDEV-SP1";
$fromEmailAddress = "rob@robdev.local";

# Search
$indexLocation = "E:\SPSearchIndexes";

# Other
$forceRemote = [bool]0;
$adminEmail = "rob@robgarrett.com";
$appDomain = "apps.robdev.local";

#PWA
$pwaWebAppUrl = "http://projects.robdev.local";
$pwaWebAppHostHeader = "projects.robdev.local";

#S2S
$appsPFX = "c:\Certs\apps.cer";
$s2sSiteUrlHttp = "http://$($lbPortalName).robdev.local";
$s2sSiteUrlHttps = "https://$($lbPortalName).robdev.local";