Param(
    [Parameter(Mandatory=$false)][String]$spVersion = "2013",
    [Parameter(Mandatory=$false)][String]$appUrl = "http://$env:computername");

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

# Source External Functions
. "$env:dp0\..\..\Install\spCommonFunctions.ps1"
. "$env:dp0\..\..\Install\spSQLFunctions.ps1"

#Get-DocInventory | Out-GridView
#Get-DocInventory | Export-Csv -NoTypeInformation -Path inventory.csv

function Iterate-SP2013($appUrl) {
    $sites = @();
    $app = Get-SPWebapplication $appUrl;
    $app.Sites | % {
        $_.AllWebs | % {
            $row = @{
                "Site Title" = $_.Title
                "URL" = $_.Url
                "SPVersion" = "2013"
            }
            $sites += (New-Object PSObject -Property $row);
        }
    }
    $sites;
}

function Iterate-SP2007($appUrl) {
    $sites = @();
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
    $farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
    foreach ($spService in $farm.Services) {
        if (!($spService -is [Microsoft.SharePoint.Administration.SPWebService])) {
            continue;
        }
        foreach ($webApp in $spService.WebApplications) {
            if ($webApp -is [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]) { continue }
            foreach ($site in $webApp.Sites) {
                if ($site.Url -cne $appUrl) { continue; }
                $site.AllWebs | % {
                    $row = @{
                        "Site Title" = $_.Title
                        "URL" = $_.Url
                        "SPVersion" = "2007"
                    }
                    $sites += (New-Object PSObject -Property $row);
                }       
                $site.Dispose()
            }
        }
    }
    $sites;
}

try {
    if ($spVersion -eq "2013") {
        SP-RegisterPS;
        Iterate-SP2013 -appUrl $appUrl | Export-Csv -NoTypeInformation -Path SP2013Sites.csv;
        Iterate-SP2013 -appUrl $appUrl | Out-GridView;
    }
    elseif ($spVersion -eq "2007") {
        Iterate-SP2007 -appUrl $appUrl | Export-Csv -NoTypeInformation -Path SP2007Sites.csv;
        Iterate-SP2007 -appUrl $appUrl | Out-GridView;
    }
}
catch {
    Write-Host -ForegroundColor Red $_.Exception;
    Pause;
}
