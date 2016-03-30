
#Can only usr powershell verison 2. Run below code first
#powershell -version 2

#cls;
[CmdletBinding()]
Param([Parameter(Mandatory=$true)][String]$userLogin);

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

#$url = "http://f052651-p-w/piw"
$url = "http://fdc1s-sp23wfed2/asd"
 
$site = New-Object Microsoft.SharePoint.SPSite($url);
$web = $site.RootWeb;
Try
{   $fullUserLogin = '{0}\{1}' -f "adferc",$userLogin;    
    $user = $web.AllUsers[$fullUserLogin];
    $user.Name        
}
Catch
 {
  #[system.exception]
  #"caught a system exception"
  Write-Host -ForegroundColor red "Error $($_.Exception)";
 }
Finally{
$site.Dispose()
}

