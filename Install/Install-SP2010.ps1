#############################################################
# SharePoint Install Everything on a single server.
# Rob Garrett
# With the help from http://autospinstaller.codeplex.com/

param ([bool]$localExec = $true)

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

# Source External Functions
. "$env:dp0\Settings\Settings-$env:COMPUTERNAME.ps1"
. "$env:dp0\spConstants.ps1"
. "$env:dp0\spCommonFunctions.ps1"
. "$env:dp0\spSQLFunctions.ps1"
. "$env:dp0\spFarmFunctions.ps1"
. "$env:dp0\spServiceFunctions.ps1"
 
# Make sure we're running as elevated.
Use-RunAsV2;
try {
    # Standard provisioning steps.
    SP-ExecCommonSPServerProvisioning
    # Create CA
    SP-CreateCentralAdmin;
    # Configure ULS
    SP-ConfigureDiagnosticLogging;
    # Install Language Packs
    SP-ConfigureLanguagePacks;
    # Configure email.
    SP-ConfigureEmail;
    # Go configure services.
    SP-ConfigureSandboxedCodeService;
    SP-CreateStateServiceApp;
    SP-CreateMetadataServiceApp;
    SP-ConfigureClaimsToWindowsTokenService;
    SP-CreateUserProfileServiceApplication;
    SP-CreateSecureStoreServiceApp;
    SP-ConfigureTracing;
    #SP-CreateBusinessDataConnectivityServiceApp;
    #SP-CreateExcelServiceApp;
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message;
}

Read-Host "Done, press enter";



