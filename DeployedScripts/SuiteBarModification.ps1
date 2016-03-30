function Set-SPSuiteBarBrandingElement {
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)][System.String]$WebAppUrl,
[Parameter(Mandatory=$true)][System.String]$LinkTarget,
[Parameter(Mandatory=$true)][System.String]$Text,
[Parameter(Mandatory=$false)][Switch]$SetTextAsHyperlink
)
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
$webApp = Get-SPWebApplication $WebAppUrl
if($SetTextAsHyperLink)
{
    $html = "<style>#ctl00_ctl53_ShellNewsfeed, #ctl00_ctl52_ShellNewsfeed, #ctl00_ctl00_ctl53_ShellNewsfeed {display:none;}</style><div class='ms-core-brandingText'><a 
href='$LinkTarget' style='color:white;'>"+$Text+"</a></div>"
}
else
{
    $html = "<div class='ms-core-brandingText'>"+$Text+"</div>"
}
$webApp.SuiteBarBrandingElementHtml = $html
$webApp.Update()
}

Set-SPSuiteBarBrandingElement -WebAppUrl "https://sp.ferc.gov" -LinkTarget "https://sp.ferc.gov/teams" -Text "FERC" -SetTextAsHyperlink