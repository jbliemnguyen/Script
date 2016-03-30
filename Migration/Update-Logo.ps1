#######################################
# Reset Site Logo

Param([Parameter(Mandatory=$true)][String]$url, [Parameter(Mandatory=$true)][String]$logoPath);

(get-spsite $url).AllWebs | foreach {$_.SiteLogoUrl = $logoPath; $_.Update()}