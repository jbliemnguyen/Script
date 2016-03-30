$pfxPath = "E:\Certs\S2S\S2SProd.pfx"
$cerPath = "E:\Certs\S2S\S2SProd.cer"
$pfxPass = "Sharepoint03"
$stsCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $pfxPath, $pfxPass, 20
Set-SPSecurityTokenServiceConfig -ImportSigningCertificate $stsCertificate -Confirm:$false;
certutil -addstore -enterprise -f -v root $cerPath
iisreset
net stop SPTimerV4
net start SPTimerV4
