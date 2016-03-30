
$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

Set-Location $env:dp0
.\Dump-URLs -srcUrl http://share.ferc.gov -destUrl http://fdc1s-sp23wfet1.ferc.gov:81 -xml share_scanresults.xml
