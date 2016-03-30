# To be run in Workflow Manager PowerShell console that has both Workflow Manager and Service Bus installed.

$pwd = 'Sharepoint03'

# Add SB Host
Write-Host -ForegroundColor white "Adding server as Service Bus Host";
$SBRunAsPassword = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
$SBCertificateAutoGenerationKey = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
Add-SBHost -SBFarmDBConnectionString 'Data Source=spsql;Initial Catalog=SPPROD_SB_Management;Integrated Security=True;Encrypt=False' `
-RunAsPassword $SBRunAsPassword -EnableFirewallRules $true -CertificateAutoGenerationKey $SBCertificateAutoGenerationKey -Verbose;

Try
{
    # Create new SB Namespace
    Write-Host -ForegroundColor white "Creating new Service Bus Namespace";
    New-SBNamespace -Name 'WorkflowDefaultNamespace' -AddressingScheme 'Path' -ManageUsers 'ADFERC\svc.spservice.prod','ADFERC\rgarrett' -Verbose;
    Start-Sleep -s 90
}
Catch [system.InvalidOperationException]
{
    Write-Host -ForegroundColor red $_.Exception;
}

# Get SB Client Configuration
$SBClientConfiguration = Get-SBClientConfiguration -Namespaces 'WorkflowDefaultNamespace' -Verbose;

# Add WF Host
Write-Host -ForegroundColor white "Adding server as Workflow Manager Host";
$WFRunAsPassword = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
$WFCertAutoGenerationKey = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
Add-WFHost -WFFarmDBConnectionString 'Data Source=spsql;Initial Catalog=SPPROD_WFM_Management;Integrated Security=True;Encrypt=False' `
-RunAsPassword $WFRunAsPassword -EnableFirewallRules $true -SBClientConfiguration $SBClientConfiguration `
-CertificateAutoGenerationKey $WFCertAutoGenerationKey -Verbose;
