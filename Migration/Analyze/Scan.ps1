Param(
    [Parameter(Mandatory=$true)][String]$profile,
    [Parameter(Mandatory=$true)][String]$spVersion);

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)

# Source External Functions
. "$env:dp0\..\Install\Settings\Settings-$env:COMPUTERNAME.ps1"
. "$env:dp0\..\Install\spCommonFunctions.ps1"
. "$env:dp0\..\Install\spSQLFunctions.ps1"
. "$env:dp0\spMigrateFunctions.ps1"
. "$env:dp0\profile$profile.ps1"

$global:data = [xml] "<Scan><Summary/><ContentDBs/></Scan>";
$global:currentDBNode = $null;
$global:summaryNode = $null;

if ($spVersion -eq "2010") { 
    $global:hive = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\14\TEMPLATE\';
}
elseif ($spVersion -eq "2013") {
    $global:hive = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\TEMPLATE\';
}
else {
    throw "Scan only supported in SharePoint 2010 and 2013";
}

function SPRun($version) {
    if ($version -eq "2010") {
        Use-RunAsV2 -additionalArg $global:argList;
    }
    else {
        Use-RunAs -additionalArg $global:argList;
    }
    SP-RegisterPS;
}

function CreateNode($name) {
    $node = $global:currentDBNode.SelectSingleNode($name);
    if ($node -eq $null) {
        $node = $global:data.CreateElement($name);
        $global:currentDBNode.AppendChild($node) | Out-Null;
    }
    return $node;
}

function ProcessFeature($feature, $scope, $url) {
    if ([string]::Compare($scope, "Site", $True) -eq 0) {
        $f = Get-SPFeature -Site $url | ? { $_.Id -eq $feature.DefinitionId }
    }
    else {
        $f = Get-SPFeature -Web $url | ? { $_.Id -eq $feature.DefinitionId }
    }
    if ($f -eq $null) {
        $featuresNode = CreateNode -name "MissingFeatures";
        if ($featuresNode.SelectSingleNode("Feature[@ID='$($feature.DefinitionId)']") -eq $null) {
            Write-Host "Found missing feature with ID: $($feature.DefinitionId)";
            $node = $global:data.CreateElement("Feature");
            $node.SetAttribute('ID', $feature.DefinitionId);
            $featuresNode.AppendChild($node) | Out-Null;
        }
    }
}

function ProcessWeb($web) {
    # Iterate the web templates
    $template = Get-SPWebTemplate | ? { $_.ID -eq $web.WebTemplateID }
    if ($template -eq $null) { 
        $siteDefsNode = CreateNode -name "MissingSiteDefs";
        if ($siteDefsNode.SelectSingleNode("SiteDef[@ID='$($web.WebTemplateID)']") -eq $null) {
            Write-Host -ForegroundColor White "Web with missing template ID $($web.URL) - Tmpl ID: $($web.WebTemplateID)";
            $node = $global:data.CreateElement("SiteDef");
            $node.SetAttribute('ID', $web.WebTemplateID);
            $node.SetAttribute('WebID', $web.ID);
            $node.SetAttribute('URL', $web.URL);
            $siteDefsNode.AppendChild($node) | Out-Null;
        }
    }
    else {
        # Iterate web features
        $web.Features | % { ProcessFeature -feature $_ -scope "Web" -url $web.Url; }
    }
}

function ProcessSummary($dbName) {
    $db = Get-SPContentDatabase | ? { $_.Name -eq $dbName }
    if ($db -eq $null) { return; }
    $db.Sites | % { 
        if ($global:summaryNode.SelectSingleNode("Site[@ID='$($_.ID)']") -eq $null) {
            $node = $global:data.CreateElement("Site");
            $node.SetAttribute('ID', $_.Id);
            $node.SetAttribute('URL', $_.Url);
            $global:summaryNode.AppendChild($node) | Out-Null;
        }
    }
}

function ProcessFeaturesAndSiteDefs($dbName) {
    $db = Get-SPContentDatabase | ? { $_.Name -eq $dbName }
    if ($db -eq $null) { return; }
    $db.Sites | % { 
        # Iterate site collection features
        $site = $_;
        $site.Features | % { ProcessFeature -feature $_ -scope "Site" -url $site.Url; }
        # Iterate webs
        $site | Get-SPWeb -Limit all | % {
            ProcessWeb -web $_;
        }
    }
}

function Run-SQLQuery ($SqlServer, $SqlDatabase, $SqlQuery) {
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server =" + $SqlServer + "; Database =" + $SqlDatabase + "; Integrated Security = True"
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()
    $DataSet.Tables[0]
}

function ProcessSetupFiles($dbName) {
    Run-SQLQuery -SqlServer "spsql" -SqlDatabase $dbName -SqlQuery `
        "SELECT DISTINCT SetupPath, SiteId, WebId, ListId from AllDocs where SetupPath IS NOT NULL" | `
            select SetupPath, SiteId, WebId, ListId | % {
            $path = $hive + $_.SetupPath;
            if (!(Test-Path $path)) {
                $setupPathsNode = CreateNode -name "MissingSetupFiles";
                if ($setupPathsNode.SelectSingleNode("SetupFile[@Path='$path']") -eq $null) {
                    Write-Host "Missing setup file $($_.SetupPath)";
                    $node = $global:data.CreateElement("SetupFile");
                    $node.SetAttribute('Path', $path);
                    $node.SetAttribute('SiteID', $_.SiteId);
                    $node.SetAttribute('WebID', $_.WebId);
                    $node.SetAttribute('ListID', $_.ListId);
                    $setupPathsNode.AppendChild($node) | Out-Null;
                }
            }
        }
}

function UpdateAttribute($node, $name, $value) {
    $existing = $node.GetAttribute($name);
    if ($existing -eq $null) {
        if ($value -eq $null) {
            $node.SetAttribute($name, '');
        }
        else {
            $node.SetAttribute($name, $value);
        }
    }
    elseif ($existing -ne $null -and $existing -ne $value) {
        $node.SetAttribute($name, $value);
    }
}

function ProcessWebParts($dbName) {
    Test-SPContentDatabase (Get-SPContentDatabase $dbName) | ? {$_.Category -eq "MissingWebPart" } | % { 
        $pattern = "\[(?<id>[a-fA-F0-9]{8}-([a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12})\]";
        if ($_.Message -imatch $pattern) {
            $wpTypeId = $matches.id;
            $query = "SELECT * from AllDocs inner join AllWebParts on AllDocs.Id = AllWebParts.tp_PageUrlID where AllWebParts.tp_WebPartTypeID = '$wpTypeId'";
            Run-SQLQuery -SqlServer "spsql" -SqlDatabase $dbName -SqlQuery $query | `
                select Id, SiteId, DirName, LeafName, WebId, ListId, tp_ZoneID, tp_DisplayName | % {
                $webPartsNode = CreateNode -name "MissingWebParts";
                $node = [System.Xml.XmlElement]$webPartsNode.SelectSingleNode("WebPart[@wpTypeID='$wpTypeId']");
                if ($node -eq $null) { 
                    $node = [System.Xml.XmlElement]$global:data.CreateElement("WebPart"); 
                    $webPartsNode.AppendChild($node) | Out-Null;
                }
                if ($_.Id -eq $null -or $_.Id -eq '') {
                    Write-Host "Missing web parts with wpTypeID $wpTypeId";    
                }
                else {
                    Write-Host "Missing web parts with wpTypeID $wpTypeId and ID $($_.Id)";    
                }
                UpdateAttribute -node $node -name 'wpTypeID' -value $wpTypeId;
                UpdateAttribute -node $node -name 'ID' -value $_.Id;
                UpdateAttribute -node $node -name 'ZoneID' -value $_.tp_ZoneID;
                UpdateAttribute -node $node -name 'DisplayName' -value $_.tp_DisplayName;
                UpdateAttribute -node $node -name 'SiteID' -value $_.SiteId;
                UpdateAttribute -node $node -name 'WebID' -value $_.WebId;
                UpdateAttribute -node $node -name 'ListID' -value $_.ListId;
            }
        }
    }
}

function ProcessAssemblies($dbName) {
    Test-SPContentDatabase (Get-SPContentDatabase $dbName) | ? {$_.Category -eq "MissingAssembly" } | % { 
        $pattern = "\[(?<assem>.+?)\]";
        if ($_.Message -imatch $pattern) {
            $assemName = $matches.assem;
            Write-Host "Missing assembly $assemName";
            $assemNode = CreateNode -name "MissingAssemblies";
            if ($assemNode.SelectSingleNode("Assembly[@Name='$assemName']") -eq $null) {
                $node = $global:data.CreateElement("Assembly");
                $node.SetAttribute('Name',$assemName);
                $assemNode.AppendChild($node) | Out-Null;
            }
        }
    }
}

function ProcessContentDB($name) {
    $node = $global:data.CreateElement('ContentDB');
    $node.SetAttribute('name',$name);
    $global:data.Scan.SelectSingleNode("ContentDBs").AppendChild($node) | Out-Null;
    $global:currentDBNode = $node;
    # Look for missing features and site definitions.
    ProcessFeaturesAndSiteDefs -dbName $name; 
    # Look for missing setup files.
    ProcessSetupFiles -dbName $name;
    # Look for missing web parts
    ProcessWebParts -dbName $name;
    # Look for missing assemblies.
    ProcessAssemblies -dbName $name;
    # Process Summary
    ProcessSummary -dbName $name;
}

# Make sure we're running as elevated.
$global:argList = $MyInvocation.BoundParameters.GetEnumerator() | Foreach {"-$($_.Key)", "$($_.Value)"}
$global:argList += $MyInvocation.UnboundArguments
try {
    SPRun -version $spVersion;
    SP-RegisterPS;
    $global:summaryNode = $global:data.Scan.SelectSingleNode("Summary");
    Time -block { 
        $action = "scan";
        Process-AllDatabases -version $spVersion -s {
            param($server, $db, $version);
            Write-Host -ForegroundColor white "Processing database $db";
            ProcessContentDB -name $db;
        }; 
    }
    $global:data.Save($env:dp0 + "\$($profile)_scanresults.xml");
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message;
}



Read-Host "Done, press enter";


