
$servers = @(
"FDC1S-SP23WFED1", "FDC1S-SP23WFED2", "FDC1S-SP23WFED3", "FDC1S-SP23WFED4",
"FDC1S-SP23WFET1", "FDC1S-SP23WFET2", "FDC1S-SP23WFET3", "FDC1S-SP23WFET4",
"FDC1S-SP23APPT1", "FDC1S-SP23APPT2", "FDC1S-SP23APPT3", "FDC1S-SP23APPT4",
"FDC1S-SP23WFEP1", "FDC1S-SP23WFEP2", "FDC1S-SP23WFEP3", "FDC1S-SP23WFEP4",
"FDC1S-SP23APPP1", "FDC1S-SP23APPP2", "FDC1S-SP23APPP3", "FDC1S-SP23APPP4");

cls
$servers | % {
    if ($_.ToUpper() -ne $env:COMPUTERNAME.ToUpper()) {
        $src = "E:\Certs"
        $dest = "\\$($_)\e$\";
        Write-Host -ForegroundColor yellow "Copying $src to $dest";
        try {
            Copy-Item $src –destination $dest -recurse -container -force
        }
        catch {
            Write-Host -ForegroundColor red "Unable to copy $src to $dest";
            Read-Host "Press enter to continue";
        }
    }
}
