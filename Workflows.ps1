if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null )
{ 
            Add-PSSnapin Microsoft.SharePoint.PowerShell
} 

###########################
# Main
###########################
cls


$spSite = Get-SPSite  "http://fdc1s-sp23wfed2/sites/LiemTest" # SiteCollection

#$allSPWebs = $spSite.AllWebs;

#$spWeb = $spSite.OpenWeb();


Write-Host("Number of sites: {0}" -f  $spSite.AllWebs.Count) -ForegroundColor Green;

foreach ($spWeb in $spSite.AllWebs)
{
    Write-Host("*********************************************");
    #$spWeb =  $allSPWebs[$i];
    Write-Host("site: {0}" -f  $spWeb.Url) -ForegroundColor Green;
    #Write-Host("Number of wf: {0}" -f  $spWeb.Workflows.Count) -ForegroundColor Yellow;
    
    foreach($list in $spWeb.Lists)
    {
        Write-Host("   List name : {0}" -f  $list.Title) -ForegroundColor Yellow;
        
        
        foreach($wf in $list.WorkflowAssociations)
        {
            Write-Host("      Workflow Name : {0}" -f  $wf.Name) -ForegroundColor Red;
        }               

    }  
    
    
    #$spWeb.Dispose(); 
}

#$spSite.Dispose();


