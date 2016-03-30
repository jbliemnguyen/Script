#############################################################
# Trigger Remote Patch Process
# Rob Garrett

$servers = @(
    "FDC1S-SP23WFET1",
    "FDC1S-SP23WFET2",
    "FDC1S-SP23APPT1",
    "FDC1S-SP23APPT2",
    "FDC1S-SP23APPT3",
    "FDC1S-SP23APPT4"
)

foreach ($s in $servers) {
    $remoteServer = "$($s).ferc.gov";
    Write-Host -ForegroundColor Yellow "Triggering $remoteServer for SharePoint Patching";
    New-EventLog -ComputerName $remoteServer -LogName Application -Source "PSWindowsUpdate" -ErrorAction SilentlyContinue;
    Write-EventLog -ComputerName $remoteServer -LogName Application -Source "PSWindowsUpdate" -EntryType Information -EventId 1 -Message "Trigger Patch Process";
}
