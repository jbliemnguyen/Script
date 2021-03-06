#####################################################
# Compare scan results

param(
[Parameter(Mandatory=$true)][string]$srcUrl, 
[Parameter(Mandatory=$true)][string]$destUrl, 
[Parameter(Mandatory=$true)][string]$xml)
 
$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

$compared = @{};

function CompareThem($url, $webID, $node) {
    if ($url -ccontains "/ssp/admin/") { return; }
    if ($url -eq $null -or $url -eq '') { return; }
    $pattern = '^' + $srcUrl;
    if ($url -cnotmatch "^$($srcUrl)" -and $url -cnotmatch "^$($destUrl)") { 
        throw "$url does not start with $srcUrl or $destUrl, are you on SP2007 server?"; 
    }
    $srcPage = $url.Trim();
    $destPage = ($srcPage -replace $pattern, $destUrl).Trim();
    # Store the pair so we're not searching again.
    $existing = $compared[$srcPage.ToUpper()];
    if ($existing -ne $null -and $existing -eq $destPage.ToUpper()) { return; }
    $compared.Add($srcPage.ToUpper(), $destPage.ToUpper());
    # Dump URLs
    $obj = New-Object PSObject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "SrcURL" -Value $srcPage;
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "DestURL" -Value $destPage;
    return $obj;
}

function CompareNode($node) {
    if ($node.ListURL -ne '') {
        return CompareThem -url ($srcUrl + $_.ListURL) -webID $_.WebID -node $node;
    }
    elseif ($node.WebURL -ne '') {
        return CompareThem -url $_.WebURL -webID $_.WebID -node $node;
    }
    elseif ($node.SiteURL -ne '') {
        return CompareThem -url $_.SiteURL -webID $_.WebID -node $node;
    }
}

function CompareScanResults($fname) {
    [xml]$data = Get-Content $fname;
    try {
        $data.Scan.ContentDBs.ContentDB | % {
            $_.MissingFeatures.Feature | % {
                $_.Site | % { CompareThem -url $_.URL -node $_; }
                $_.Web | % { CompareThem -url $_.URL -node $_; }
            }
            $_.MissingSiteDefs.SiteDef | % {
                CompareThem -url $_.URL -webID $_.WebID -node $_;
            }
            $_.MissingSetupFiles.SetupFile | % {
                CompareNode -node $_;
            }
            $_.MissingAssemblies.Assembly | % {
                $_.List | % { CompareThem -url ($srcUrl + $_.URL) -node $_; }
            }
        }
    }
    catch {
        throw $_.Exception; 
    }
}

try {
    CompareScanResults -fname ($xml) | Out-GridView;
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message;
}

Read-Host "Done, press enter";