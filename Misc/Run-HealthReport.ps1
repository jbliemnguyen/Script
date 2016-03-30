if ($PSVersionTable) {$Host.Runspace.ThreadOptions = 'ReuseThread'}
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
 
# get the health reports list
$ReportsList = [Microsoft.SharePoint.Administration.Health.SPHealthReportsList]::Local
$FormUrl = '{0}{1}?id=' -f $ReportsList.ParentWeb.Url, $ReportsList.Forms.List.DefaultDisplayFormUrl
 
$body = $ReportsList.Items | Where-Object {$_['Severity'] -ne '4 - Success'} | ForEach-Object {
 
    New-Object PSObject -Property @{
        Url = "<a href='$FormUrl$($_.ID)'>$($_['Title'])</a>"
        Severity = $_['Severity']
        Category = $_['Category']
        Explanation = $_['Explanation']
        Modified = $_['Modified']
        FailingServers = $_['Failing Servers']
        FailingServices = $_['Failing Services']
        Remedy = $_['Remedy']
    }
 
} | ConvertTo-Html | Out-String

# creating clickable HTML links
$body = $body -replace '&lt;','<' -replace '&gt;','>' -replace '&quot;','"'
 
$params = @{
   To = 'robert.garrett@ferc.gov'
   From = 'sharepoint@ferc.gov'
   Subject = "Daily Health Analyzer report for $($env:computername)"
   SmtpServer = 'mailrelay.ferc.gov'
   Body = $body
   BodyAsHtml = $true
}
 
Send-MailMessage @params