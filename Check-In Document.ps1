
Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Stop;

function CheckInDocument([string]$url)
{
$spWeb = Get-SPWeb -site $url
$getFolder = $spWeb.GetFolder("Security%20Waiver%20Forms")
$files = $getFolder.Files | Where { $_.CheckOutStatus -ne "None" }
Write-Host("Check out file:");
foreach($file in $files)
{
    Write-Host "$file"
    $file.CheckIn("");    
    # To: ($file.CheckedOutBy)
    #$_.CheckIn("Checked In By Administrator")
    #Write-Host "$($_.Name) Checked In" -ForeGroundColor Green
}
$spWeb.Dispose()
}

###########################
# Main
###########################
cls

Try
{
    #Reset-InfoPathTemplateLink "\\fdc1s-sp23wfed2\itsecurity\Security%20Waiver%20Forms" "*.xml"
    CheckInDocument "http://fdc1s-sp23wfed2/itsecurity"
}
Catch
{    
    Write-Host($_.Exception.Message);
}