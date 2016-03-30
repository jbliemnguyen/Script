#############################################################
# SharePoint Configure Logs.
# Rob Garrett

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

# Source External Functions
. "$env:dp0\Settings\Settings-$env:COMPUTERNAME.ps1"
. "$env:dp0\spConstants.ps1"
. "$env:dp0\spCommonFunctions.ps1"
. "$env:dp0\spSQLFunctions.ps1"
. "$env:dp0\spFarmFunctions.ps1"
. "$env:dp0\spRemoteFunctions.ps1"
. "$env:dp0\spServiceFunctions.ps1"
. "$env:dp0\spSearchFunctions.ps1"
. "$env:dp0\spWFMFunctions.ps1"
 
# Make sure we're running as elevated.
Use-RunAs;
try {
    SP-RegisterPS;
    $Farm = Get-SPFarm
    $Name = "SPDistributedCacheCluster_" + $Farm.Id.ToString()
    $Manager = [Microsoft.SharePoint.DistributedCaching.Utilities.SPDistributedCacheClusterInfoManager]::Local
    $Info = $Manager.GetSPDistributedCacheClusterInfo($Name);
    $instance ="SPDistributedCacheService Name=AppFabricCachingService"
    $serviceInstance = Get-SPServiceInstance | ? {($_.Service.Tostring()) -eq $instance -and ($_.Server.Name) -eq $env:computername}

    if([System.String]::IsNullOrEmpty($Info.CacheHostsInfoCollection)) {
        $serviceInstance.Delete()
        #Add-SPDistributedCacheServiceInstance
        $Info.CacheHostsInfoCollection
    }
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message;
}

Pause;




 