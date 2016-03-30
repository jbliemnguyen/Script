#############################################################
# Patch SharePoint with Windows Update
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
    Import-Module PSWindowsUpdate;
    $timeStamp = Get-Date;
    Out-File -FilePath C:\PSWindowsUpdate.log -Append -InputObject "$timeStamp Starting Patch Process";
    Get-WUInstall -MicrosoftUpdate -Title "SharePoint" -AcceptAll -Verbose | Out-File c:\PSWindowsUpdate.log -Append
    <#
    SP-RegisterPS;
    $hive = [Microsoft.SharePoint.Utilities.SPUtility]::GetGenericSetupPath("");
    Set-Location "$($hive)bin" 
    PSConfig.exe -cmd upgrade -inplace b2b -force -cmd applicationcontent -install -cmd installfeatures
    #>
    $timeStamp = Get-Date;
    Out-File -FilePath C:\PSWindowsUpdate.log -Append -InputObject "$timeStamp Patch Process Complete";
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message | Out-File C:\PSWindowsUpdate.log -Append
}






