# create new Log list with a column: Message
# create alert for the Log list, email to .......
Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Stop;

function LogItems($Message){

#get the spweb object
$web = Get-SPWeb $siteURL;

#get the splist object of the Log list
$list = $web.Lists[$ListName];
#create new item
$newItem = $list.Items.Add();
$newItem["Message"] = $Message;
$newItem.Update();
}


Try
{
    if (date)
    {
        Clear-Variable date;
    }
    $siteURL = "http://fdc1s-sp23wfed2/sites/asd";
    $ListName = "Log";    
    $date = Get-Date -Format "MM_dd_yyyy_h_mm_ss";
    #$backUpPath = "C:\Users\lnguyen\Desktop\ASD\SiteBackUp\" + $date + ".bak"; 
    $backUpPath = "\\FDC1S-SP23WFED2\SiteBackUp\" + $date + ".bak";     


    Backup-SPSite $siteURL -Path $backUpPath -ErrorAction Stop;
    
    LogItems "Sucessfully backup ASD Site";
}
Catch
{    
    LogItems "Fail to backup ASD Site";
}



