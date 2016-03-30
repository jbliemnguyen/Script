#############################################################
# Upgrade SharePoint
# Rob Garrett

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

# Source External Functions
. "$env:dp0\..\Install\Settings\Settings-$env:COMPUTERNAME.ps1"
. "$env:dp0\..\Install\spConstants.ps1"
. "$env:dp0\..\Install\spCommonFunctions.ps1"
 
# Make sure we're running as elevated.
Use-RunAs;
try {
    SP-RegisterPS;
    $hive = [Microsoft.SharePoint.Utilities.SPUtility]::GetGenericSetupPath("");
    Set-Location "$($hive)bin" 
    PSConfig.exe -cmd upgrade -inplace b2b -force -cmd applicationcontent -install -cmd installfeatures
    $timeStamp = Get-Date;
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message | Out-File C:\PSWindowsUpdate.log -Append
}






