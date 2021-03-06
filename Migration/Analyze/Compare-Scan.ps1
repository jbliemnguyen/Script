#####################################################
# Compare scan results

param(
[Parameter(Mandatory=$true)][string]$srcUrl, 
[Parameter(Mandatory=$true)][string]$destUrl, 
[Parameter(Mandatory=$true)][string]$xml)
 
$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

$compared = @{};
$global:bmFound = $false;

function MyChoice {
    $caption = "Choose Action.";
    $message = "What Now?";
    $quit = new-Object System.Management.Automation.Host.ChoiceDescription "&Quit","Quit";
    $next = new-Object System.Management.Automation.Host.ChoiceDescription "&Next","Next";
    $bookmark = new-Object System.Management.Automation.Host.ChoiceDescription "&Bookmark","Bookmark";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($quit,$next,$bookmark);
    $ans = $host.ui.PromptForChoice($caption,$message,$choices,1);
    switch ($ans) {
        0 { return "QUIT"; }
        1 { return "NEXT"; }
        2 { return "BOOKMARK"; }
    }
    return '';
}

function Bookmark($node, $bm) {
    if ($node -eq $null) { return; }
    # If BK is empty or null then remove BM.
    if ($bm -eq $null -or $bm -eq '') {
        $node.RemoveAttribute("Bookmark");
    }
    else {
        $node.SetAttribute("Bookmark", $bm);
    }
}

function CompareThem($url, $webID, $node) {
    if ($url -ccontains "/ssp/admin/") {
        Write-Host -foregroundcolor yellow "Skipping $url because it's a legacy admin site";
        return;
    }
    if ($global:bmFound -eq $false) {
        # Have we found the bookmark?
        if ($node -ne $null -and $node.GetAttribute("Bookmark") -eq "Pause") {
            $global:bmFound = $true;
        } 
        else {
            return;
        }
    }
    Bookmark -node $node;
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
    # Launch IE.
    Write-Host "Launching IE to compare $srcPage with $destPage";
    $navOpenInBackgroundTab = 0x1000;
    try {
        OpenIETab -url $srcPage -tab 0;
        OpenIETab -url $destPage -tab 1;
        $answer = MyChoice;
        if ($answer -eq "QUIT") {
            throw $answer;
        }
        elseif ($answer -eq "BOOKMARK") {
            Bookmark -node $node -bm 'Pause';
            throw $answer;
        }
    }
    catch {
        if ($answer -ne '') { throw $_.Exception; }
    }
    finally {
        $ie = $null;
    }
}

function OpenIETab($url, [int]$tab) {
    $ie = (New-Object -comObject Shell.Application).Windows() | ? {$_.Name -eq "Internet Explorer"}
    if ($ie -eq $null) {
        Write-Host -ForegroundColor yellow "Launching Internet Explorer";
        $ie = @(new-object -com InternetExplorer.Application);
        $ie.Navigate($url);
        Start-Sleep 2
    }
    elseif ($ie -is [system.array]) {
        # Must have at least 2 instances open.
        if ($tab -lt $ie.Count) {
            $ie[$tab].Navigate($url);
            Start-Sleep 2
        }
    }
    else {
        # One existing instance open, so open a new tab
        # Note, if the zone changes a new browser window will open.
        $ie.Navigate2($destPage, 2048);
        Start-Sleep 2
    }
}

function CompareNode($node) {
    if ($node.ListURL -ne '') {
        CompareThem -url ($srcUrl + $_.ListURL) -webID $_.WebID -node $node;
    }
    elseif ($node.WebURL -ne '') {
        CompareThem -url $_.WebURL -webID $_.WebID -node $node;
    }
    elseif ($node.SiteURL -ne '') {
        CompareThem -url $_.SiteURL -webID $_.WebID -node $node;
    }
}

function CompareScanResults($fname) {
    [xml]$data = Get-Content $fname;
    try {
        # Look for bookmark.
        $bmNode = $data.SelectSingleNode("//*[@Bookmark='Pause']");
        if ($bmNode -ne $null) {
            Write-Host -foregroundcolor yellow "Skipping to last known bookmark";
            $global:bmFound = $false;
        }
        else {
            $global:bmFound = $true;
        }
        $data.Scan.ContentDBs.ContentDB | % {
            Write-Host -foregroundcolor yellow "Processing content DB$($_.name)";
            Write-Host -foregroundcolor yellow " - Processing missing features";
            $_.MissingFeatures.Feature | % {
                $_.Site | % { CompareThem -url $_.URL -node $_; }
                $_.Web | % { CompareThem -url $_.URL -node $_; }
            }
            Write-Host -foregroundcolor yellow " - Processing missing site definitions";
            $_.MissingSiteDefs.SiteDef | % {
                CompareThem -url $_.URL -webID $_.WebID -node $_;
            }
            Write-Host -foregroundcolor yellow " - Processing missing setup files";
            $_.MissingSetupFiles.SetupFile | % {
                CompareNode -node $_;
            }
            Write-Host -foregroundcolor yellow " - Processing missing assemblies";
            $_.MissingAssemblies.Assembly | % {
                $_.List | % { CompareThem -url ($srcUrl + $_.URL) -node $_; }
            }
        }
    }
    catch {
        if ($_.Exception.Message -ne "QUIT" -and $_.Exception.Message -ne "BOOKMARK") {
            throw $_.Exception; 
        }
    }
    Write-Host -foregroundcolor yellow "Updating XML file $fname";
    $data.Save($fname);
}

try {
    cls;
    get-process | ? { $_.ProcessName -eq "IEXPLORE" } | Stop-Process
    CompareScanResults -fname ($xml);
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message;
}

Read-Host "Done, press enter";