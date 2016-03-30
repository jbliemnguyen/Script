Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction Stop;


function Reset-InfoPathTemplateLink {
Param(
[string]$FilePath,
[string]$FileExtension,
[string]$oldTemplateLocation,
[string]$newTemplateLocation
)
Write-Host("***************************************") -ForegroundColor Green;;
Write-Host("Start Reset Form") -ForegroundColor Green;;
$files = Get-ChildItem $FilePath -Filter $FileExtension

$count = 0;
    foreach ($file in $files) {
        $count++;
        $fileContent = Get-Content $file.fullname;                
        (Get-Content $file.fullname) | ForEach-Object {$_ -replace $oldTemplateLocation,$newTemplateLocation} | Set-Content $file.fullname
        Write-Host($file.fullname);                

    } #end foreach

  

} #end function


function CheckInDocument([string]$url,[string]$folderName)
{
Write-Host("***************************************") -ForegroundColor Green;;
Write-Host("Start Check In") -ForegroundColor Green;;
$spWeb = Get-SPWeb -site $url
$getFolder = $spWeb.GetFolder($folderName)
$files = $getFolder.Files | Where { $_.CheckOutStatus -ne "None" }
Write-Host("Check out file:");
foreach($file in $files)
{
    Write-Host "$file"
    #$file.CheckIn("");        
}
$spWeb.Dispose()
}

###########################
# Main
###########################
cls

Try
{

    ########################### Dev ###########################
    #Reset-InfoPathTemplateLink "\\fdc1s-sp23wfed2\itsecurity\Security%20Waiver%20Forms" "*.xml" "https://sp.ferc.gov/itsecurity/Security%20Waiver%20Forms/Forms/template.xsn" "http://fdc1s-sp23wfed2/itsecurity/Security%20Waiver%20Forms/Forms/template.xsn"
    #Reset-InfoPathTemplateLink "\\fdc1s-sp23wfed2\itsecurity\Security%20Waiver%20Forms" "*.xml" "http://fdc1s-sp23wfed2/itsecurity/Security%20Waiver%20Forms/Forms/template.xsn" "https://sp.ferc.gov/itsecurity/Security%20Waiver%20Forms/Forms/template.xsn"
    #CheckInDocument "http://fdc1s-sp23wfed2/itsecurity" "Security%20Waiver%20Forms"


    CheckInDocument "https://sp.ferc.gov/teams/SiteDirectory/GDProgram/GDIT%20Weekly%20Activity%20Report%2012292014%20-%2001022015" "Shared%20Documents"

    ########################### End Dev###########################


    ########################### Prod ###########################
    #Reset-InfoPathTemplateLink "\\fdc1s-sp23wfep1.ferc.gov\itsecurity\Security%20Waiver%20Forms" "*.xml" "http://share.ferc.gov/SiteDirectory/itsecurity/Security%20Waiver%20Forms/Forms/template.xsn" "https://sp.ferc.gov/itsecurity/Security%20Waiver%20Forms/Forms/template.xsn"
    #\\fdc1s-sp23wfep1.ferc.gov\itsecurity\Security%20Waiver%20Forms
    #\\sp.ferc.gov\itsecurity\Security%20Waiver%20Forms

    #CheckInDocument "https://sp.ferc.gov/itsecurity" "Security%20Waiver%20Forms"
    ########################### End Prod ###########################

    
}
Catch
{    
    Write-Host("Script failed");
}