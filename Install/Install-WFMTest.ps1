# To be run in Workflow Manager PowerShell console that has both Workflow Manager and Service Bus installed.

$pwd = 'Sharepoint03'

# Create new SB Farm
Write-Host -ForegroundColor white "Creating new Service Bus Farm";
$SBCertificateAutoGenerationKey = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
New-SBFarm -SBFarmDBConnectionString 'Data Source=SPSQL;Initial Catalog=SPTEST_SB_Management;Integrated Security=True;Encrypt=False' `
-InternalPortRangeStart 9000 -TcpPort 9354 -MessageBrokerPort 9356 -RunAsAccount 'ADFERC\svc.spservice.test' -AdminGroup 'BUILTIN\Administrators' `
-GatewayDBConnectionString 'Data Source=SPSQL;Initial Catalog=SPTEST_SB_Gateway;Integrated Security=True;Encrypt=False' `
-CertificateAutoGenerationKey $SBCertificateAutoGenerationKey -MessageContainerDBConnectionString `
'Data Source=SPSQL;Initial Catalog=SPTEST_SB_MessageContainer;Integrated Security=True;Encrypt=False' -Verbose;

# Create new WF Farm
Write-Host -ForegroundColor white "Creating new Workflow Manager Farm";
$WFCertAutoGenerationKey = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
New-WFFarm -WFFarmDBConnectionString 'Data Source=SPSQL;Initial Catalog=SPTEST_WFM_Management;Integrated Security=True;Encrypt=False' `
-RunAsAccount 'ADFERC\svc.spservice.test' -AdminGroup 'BUILTIN\Administrators' -HttpsPort 12290 -HttpPort 12291 -InstanceDBConnectionString `
'Data Source=SPSQL;Initial Catalog=SPTEST_WFM_InstanceManagement;Integrated Security=True;Encrypt=False' -ResourceDBConnectionString `
'Data Source=SPSQL;Initial Catalog=SPTEST_WFM_ResourceManagement;Integrated Security=True;Encrypt=False' -CertificateAutoGenerationKey `
$WFCertAutoGenerationKey -Verbose;

# Add SB Host
Write-Host -ForegroundColor white "Adding server as Service Bus Host";
$SBRunAsPassword = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
Add-SBHost -SBFarmDBConnectionString 'Data Source=SPSQL;Initial Catalog=SPTEST_SB_Management;Integrated Security=True;Encrypt=False' `
-RunAsPassword $SBRunAsPassword -EnableFirewallRules $true -CertificateAutoGenerationKey $SBCertificateAutoGenerationKey -Verbose;

Try
{
    # Create new SB Namespace
    Write-Host -ForegroundColor white "Creating new Service Bus Namespace";
    New-SBNamespace -Name 'WorkflowDefaultNamespace' -AddressingScheme 'Path' -ManageUsers 'ADFERC\svc.spservice.test','ADFERC\rgarrett' -Verbose;
    Start-Sleep -s 90
}
Catch [system.InvalidOperationException]
{
    Write-Host -ForegroundColor red $_.Exception;
}

Read-Host "Press any key to continue";

# Get SB Client Configuration
$SBClientConfiguration = Get-SBClientConfiguration -Namespaces 'WorkflowDefaultNamespace' -Verbose;

# Add WF Host
Write-Host -ForegroundColor white "Adding server as Workflow Manager Host";
$WFRunAsPassword = ConvertTo-SecureString -AsPlainText  -Force  -String $pwd -Verbose;
Add-WFHost -WFFarmDBConnectionString 'Data Source=SPSQL;Initial Catalog=SPTEST_WFM_Management;Integrated Security=True;Encrypt=False' `
-RunAsPassword $WFRunAsPassword -EnableFirewallRules $true -SBClientConfiguration $SBClientConfiguration -CertificateAutoGenerationKey `
$WFCertAutoGenerationKey -Verbose;
