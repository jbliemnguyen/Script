##################################################
# Uber Migration Script

Param([switch]$alertMe);

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$env:dp0\..\Install\spCommonFunctions.ps1"

function ProcessProfiles($action, $profileName, $version) {
    Write-Host -ForegroundColor black -BackgroundColor yellow "Performing $action action for profile $profileName";
    Set-Location $env:dp0;
    if ($alertMe) {
        .\Migrate-SQLData.ps1 -action $action -profile $profileName -spVersion $version -noPauseAtEnd -alertMe;
    }
    else {
        .\Migrate-SQLData.ps1 -action $action -profile $profileName -spVersion $version -noPauseAtEnd;
    }
}

function SPRun($version) {
    if ($version -eq "2010") {
        Use-RunAsV2 -additionalArg $global:argList;
    }
    else {
        Use-RunAs -additionalArg $global:argList;
    }
    SP-RegisterPS;
}

# Main
$global:argList = $MyInvocation.BoundParameters.GetEnumerator() | ? { $_.Value.GetType().Name -ne "SwitchParameter" } | % {"-$($_.Key)", "$($_.Value)"}
$switches = $MyInvocation.BoundParameters.GetEnumerator() | ? { $_.Value.GetType().Name -eq "SwitchParameter" } | % {"-$($_.Key)"}
if ($switches -ne $null) { $global:argList += $switches; }
$global:argList += $MyInvocation.UnboundArguments
SPRun -version $spVersion;

########### SP2007 -> SP2010 ###########

if ($env:COMPUTERNAME.ToUpper() -eq "FDC1S-SP23WFED4") {
    # Clean
    ProcessProfiles -action clean -profileName test -version 2010
    ProcessProfiles -action clean -profileName share3 -version 2010
    ProcessProfiles -action clean -profileName share -version 2010
    # Backup
    ProcessProfiles -action backup -profileName test -version 2007
    ProcessProfiles -action backup -profileName share3 -version 2007
    ProcessProfiles -action backup -profileName share -version 2007
    # Restore
    ProcessProfiles -action restore -profileName test -version 2010
    ProcessProfiles -action restore -profileName share3 -version 2010
    ProcessProfiles -action restore -profileName share -version 2010
    # Mount
    ProcessProfiles -action mount -profileName test -version 2010
    ProcessProfiles -action mount -profileName share3 -version 2010
    ProcessProfiles -action mount -profileName share -version 2010
}

########### SP2010 -> SP2013 ###########
if ($env:COMPUTERNAME.ToUpper() -eq "FDC1S-SP23APPT1") {
    # Clean
    ProcessProfiles -action clean -profileName test -version 2013
    ProcessProfiles -action clean -profileName share3 -version 2013
    ProcessProfiles -action clean -profileName share -version 2013
    # Backup (CFO backed up with nightly job)
    ProcessProfiles -action backup -profileName test -version 2010
    ProcessProfiles -action backup -profileName share3 -version 2010
    ProcessProfiles -action backup -profileName share -version 2010
    # Restore
    ProcessProfiles -action restore -profileName test -version 2013
    ProcessProfiles -action restore -profileName share3 -version 2013
    ProcessProfiles -action restore -profileName share -version 2013
    # Mount
    ProcessProfiles -action mount -profileName test -version 2013
    ProcessProfiles -action mount -profileName share3 -version 2013
    ProcessProfiles -action mount -profileName share -version 2013
    # Consolidate
    ProcessProfiles -action consolidate -profileName test -version 2013
    ProcessProfiles -action consolidate -profileName share3 -version 2013
    ProcessProfiles -action consolidate -profileName share -version 2013
}

Read-Host "Finished, press enter";
