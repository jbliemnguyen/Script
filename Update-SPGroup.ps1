param(
    [ValidateSet("DEV","TEST","PROD")]
    [parameter(mandatory=$true)]
    [string]$Environment = ("DEV","TEST","PROD")
)

Clear-Host
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

$hostName = $env:COMPUTERNAME

$Environments = @{
     "DEV" =
    @{
        "WebAppUrl" = "https://$($hostName).ferc.gov"        
     }
    "TEST" = 
    @{
        "WebAppUrl" = "https://oaltest.sp.ferc.gov/"        
     }
     "PROD" = 
     @{
        "WebAppUrl" = "https://oal.sp.ferc.gov/"        
     }
}


function SPACER {
    Write-Host "******************************"
}

function Get-SPGroup {
    [CmdletBinding()]
    Param(
    [string]$WebURL,
    [string]$Group
    )
$SPWeb = Get-SPWeb $WebURL
if ($SPWeb -ne $null){
$SPGroup = $SPWeb.SiteGroups | Where-Object{$_.Name -like $Group}
$SPWeb.Dispose()
return $SPGroup}

}


function Set-SPGroupOwner{
[CmdletBinding()]
    Param(    
    [string]$siteCollectionURL
    )

    SPACER
    Write-Host "Site Collection URL: " $siteCollectionURL
    #$ownerGroups = (Get-SPGroup -Web $siteCollectionURL -Group "*Owners")

    
        $ownerGroup = (Get-SPWeb $siteCollectionURL).AssociatedOwnerGroup
        if ($ownerGroup -ne $null)
        {
            Write-Host "Owners group found" -BackgroundColor Yellow
            $groups = Get-SPGroup -Web $siteCollectionURL -Group "*"

            if ($groups -ne $null){            
                $groups| foreach{
                $_.Owner = $ownerGroup
                $_.Update()
                Write-Host "Updated" $_.Name "group"
                }
            SPACER
            }
        }
    


}


#Main
$WebAppUrl = $Environments.Get_Item($Environment).WebAppUrl;
Get-SPSite -WebApplication $WebAppUrl -Limit All | Where-Object {$_.Url -like "*Sites*"} | ForEach-Object {
			Set-SPGroupOwner -siteCollectionURL $_.URL;        			
}






