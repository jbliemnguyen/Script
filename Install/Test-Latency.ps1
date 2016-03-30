<#
//*********************************************************
// THIS CODE IS PROVIDED AS IS WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
// ©2013 Microsoft Corporation. All rights reserved.
//*********************************************************
#>
# Edit these variables to match your environment
$SPServerNames = `
"FDC1S-SP23APPT1", "FDC1S-SP23APPT2", "FDC1S-SP23APPT3", "FDC1S-SP23APPT4", "FDC1S-SP23WFET1", "FDC1S-SP23WFET2", "FDC1S-SP23SQLT1", `
"FDC1S-SP23APPP1", "FDC1S-SP23APPP2", "FDC1S-SP23APPP3", "FDC1S-SP23APPP4", "FDC1S-SP23WFEP1", "FDC1S-SP23WFEP2", "FDC1S-SP23SQLP1", `
"FDC1S-SP23WFED1", "FDC1S-SP23WFED2", "FDC1S-SP23WFED3", "FDC1S-SP23WFED4", "FDC1S-SP23SQLD1"
$SQLServerNames = `
"FDC1S-SP23SQLT1", , "FDC1S-SP23SQLP1", "FDC1S-SP23SQLD1\SHAREPOINTD1", "FDC1S-SP23SQLD1\SHAREPOINTD2", `
"FDC1S-SP23SQLD1\SHAREPOINTD3", "FDC1S-SP23SQLD1\SHAREPOINTINT"
#Edit this if you want to change the durations of the ping test (in minutes)
$RunTime = 10
### test connectivity ###
Write-Host "Test Connectivity:"
Write-Host "Testing Ping"
$ping = New-Object System.Net.NetworkInformation.ping
for($i=0; $i -le $SPServernames[$i].Length-1; $i++){
    Write-Host "  Pinging $($SPServerNames[$i])"
    $status = $ping.send($SPServernames[$i]).Status
        
    if($status -ne "Success"){
        throw "Ping Failed to $($SPSServernames[$i])"
        }
    }
    
Write-Host " - Succeeded `n"
### test SQL connectivity ###
#Connect to SQL using SQlCLient the same way that SharePoint Does
foreach ($s in $SQLServerNames) {
    Write-Host "Testing SQL Connection for $s"
    $SQLConnection = New-Object System.Data.SQLClient.SQLConnection("Data Source=$s;Integrated Security=True")
    $SQLConnection.Open()
    if($SQLConnection.state -ne "Open"){
        throw "SQL Connection Failed"
    }
    Write-Host " - Succeeded `n"
}
### Intra-server latency consistency test ###
Write-Host "Starting network consistency tests @ $([DateTime]::Now)"
$ScriptBlock = {
    # accept the loop variable across the job-context barrier
    param($InHost, $RunTime) 
    $start = [DateTime]::Now
    $ping = New-Object System.Net.NetworkInformation.ping
    
    $PingResults = @()
    while([datetime]::now -le $start.AddMinutes($RunTime)){ 
        $outping = $ping.send($InHost)
        if($outping.Status -ne "Success"){
            $PingResults = $PingResults + 100
            } else{
            $PingResults = $PingResults + $outping.RoundtripTime
            }
        Start-Sleep .1
        } 
    return $PingResults
    }
#run ping jobs in parallel
foreach($i in $SPServernames){
    Start-Job $ScriptBlock -ArgumentList $i, $RunTime -Name "$i.latency_test"
}
Write-Host "`nGathering statistics for $($RunTime) minutes... `n"
#wait and clean up
While (Get-Job -State "Running") { Start-Sleep $($runTime/2) }
$output = @{}
foreach($i in $SPServernames){
    $output[$i] = Receive-Job -Name "$i.latency_test"
}
Remove-Job *
#test results
Write-Host "Processing Data... `n"
$BadPings = @{}
$PercentBadPings = @{}
foreach($i in $SPServernames){
    $BadPings[$i] = $output[$i] | ?{$_ -ge 1}
    $TotalPings = $output[$i].Length
    $PercentBadPingsOver5Ms =  ($BadPings[$i] | ?{$_ -ge 5}).length/$TotalPings * 100
    $PercentBadPingsOver4Ms =  ($BadPings[$i] | ?{$_ -ge 4}).length/$TotalPings * 100
    $PercentBadPingsOver3Ms =  ($BadPings[$i] | ?{$_ -ge 3}).length/$TotalPings * 100
    $PercentBadPingsOver2Ms =  ($BadPings[$i] | ?{$_ -ge 2}).length/$TotalPings * 100
    $PercentBadPingsOver1Ms =  ($BadPings[$i] | ?{$_ -ge 1}).length/$TotalPings * 100
      
    if($PercentBadPingsOver1Ms -ge .1)
    {
        "{0} DOES NOT meet the latency requirements with {1:N2}% of pings >1ms" -f $i, $PercentBadPingsOver1Ms  
        "  ({0:N2}% > 5ms, {1:N2}% > 4ms, {2:N2}% > 3ms, {3:N2}% > 2ms, {4:N2}% > 1ms)`n" -f $PercentBadPingsOver5Ms,$PercentBadPingsOver4Ms,$PercentBadPingsOver3Ms,$PercentBadPingsOver2Ms,$PercentBadPingsOver1Ms
    } 
        else
        {
        "{0} meets the latency requirements with {1:N2}% of pings >1ms`n" -f $i, $PercentBadPingsOver1Ms
        }
    $LatencyTestFailed = 1
    }
    
#if($LatencyTestFailed -eq 1){
#    throw "Farm Latency Test Failed"
#    } 