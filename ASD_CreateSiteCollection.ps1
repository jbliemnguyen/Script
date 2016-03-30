Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Stop;
New-SPSite -URL "http://fdc1s-sp23wfed2/sites/ASD_test" -OwnerAlias "adferc\lnguyen" -ContentDatabase WFED2_Content_ASD