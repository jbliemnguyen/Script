#####################################################
# Annotate scan results
 
Param([Parameter(Mandatory=$true)][String]$profile)
 
$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)
 
function IterateFarm {
    param ([parameter(Mandatory=$true)][string]$func, $myArgs)
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
    $farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
    foreach ($spService in $farm.Services) {
        # Ignore SSP
        if (!($spService -is [Microsoft.SharePoint.Administration.SPWebService])) {
            continue;
        }
        # Iterate each web app.
        foreach ($webApp in $spService.WebApplications) {
            # Skip administration sites.
            if ($webApp -is [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]) { continue }
            # Iterate content databases (we have to use reflection - eww).
            foreach ($db in $webApp.ContentDatabases) {
                $method = [Microsoft.SharePoint.Administration.SPContentDatabase].getmethod("get_Sites"); 
                $sites = $method.Invoke($db, "instance,public", $null, $null, $null);
                # Iterate each site collection.
                foreach ($site in $sites) {
                    & $func -site $site -myArgs $myArgs;
                    # Iterate each web.
                    for ($i = 0; $i -lt $site.AllWebs.Count; $i++) {
                        $web = $site.AllWebs[$i];
                        Try {
                            & $func -web $web -site $site -myArgs $myArgs;
                        }
                        Catch {
                            Write-Host -foregroundcolor red "Error accessing" $web.Url
    			            Write-Host -foregroundcolor red $_.Exception.Message;
                        }
                        Finally {
                            $web.Dispose();
                        }
                    }
                    $site.Dispose()
                }
            }            
        }
    }
}
  
function PopulateFeatureNode($node, $feature) {
    if ($feature.Definition -ne $null -and $node -ne $null) {
        $node.SetAttribute("DisplayName", $feature.Definition.DisplayName);
        $node.SetAttribute("RootDirectory", $feature.Definition.RootDirectory);
        $node.SetAttribute("ReceiverClass", $feature.Definition.ReceiverClass);
        $node.SetAttribute("ReceiverAssembly", $feature.Definition.ReceiverAssembly);
        $node.SetAttribute("Hidden", $feature.Definition.Hidden);
        # Is the feature a workflow?
        if ($feature.Definition.ReceiverClass -eq "Microsoft.Office.Workflow.Feature.WorkflowFeatureReceiver") {
            $where = $feature.Definition.RootDirectory + "\workflow.xml";
            [xml]$data = Get-Content $where;
            if ($data -eq $null) {
                Write-Host -foregroundcolor Red "Cannot find $where";
                return;
            }
            $wfId = $data.Elements.Workflow.Id;
            if ($wfId -eq $null -or $wfId -eq "") {
                Write-Host -foregroundcolor Red "Cannot find ID of workflow";
                return;
            }
            $node.SetAttribute("WorkflowID", $wfId);
        }
    }
}
  
function ProcessFeature($site, $web, $myArgs) {
    if ($myArgs -eq $null) { return; }
    if ($web -ne $null) {
        $web.Features | ? { $_.DefinitionId -eq $myArgs[0] } | % {
            PopulateFeatureNode -node $myArgs[1] -feature $_;
            if ($myArgs[1].SelectSingleNode("Web[@ID='$($web.ID)']") -eq $null) {
                $webNode = $myArgs[1].OwnerDocument.CreateElement("Web");
                $webNode.SetAttribute("ID", $web.ID);
                $webNode.SetAttribute("URL", $web.Url);
                $myArgs[1].AppendChild($webNode) | Out-Null;
            }
        }
    }
    elseif ($site -ne $null) {
        $site.Features | ? { $_.DefinitionId -eq $myArgs[0] } | % {
            PopulateFeatureNode -node $myArgs[1] -feature $_;
            if ($myArgs[1].SelectSingleNode("Site[@ID='$($site.ID)']") -eq $null) {
                $siteNode = $myArgs[1].OwnerDocument.CreateElement("Site");
                $siteNode.SetAttribute("ID", $site.ID);
                $siteNode.SetAttribute("URL", $site.Url);
                $myArgs[1].AppendChild($siteNode) | Out-Null;
            }
        }
    }
}
 
function ProcessWFAssociations($site, $web, $myArgs) {
    if ($site -eq $null -or $web -eq $null) { return; }
    $wfm = $site.WorkflowManager;
    $web.Lists | % { $_.WorkflowAssociations | % { 
        # Find node in the XML.
        $baseId = $_.BaseId;
        $name = $_.InternalName;
        $myArgs.SelectNodes("MissingFeatures/Feature[@WorkflowID='$baseId']") | % {
            Write-Host "Found Workflow association for Workflow with ID $baseId and name $name";
            if ($_.SelectSingleNode("WFAssociation[@ID='$baseId']") -eq $null) {
                $node = $_.OwnerDocument.CreateElement("WFAssociation");
                $node.SetAttribute("ID", $baseId);
                if ($web -ne $null) { 
                    $node.SetAttribute("URL", $web.Url);
                } elseif ($site -ne $null) {
                    $node.SetAttribute("URL", $site.Url);
                }
                $node.SetAttribute("Name", $name);
                $_.AppendChild($node) | Out-Null;
            }    
        }
    }}
}

function GetSite($id) {
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
    $farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
    foreach ($spService in $farm.Services) {
        # Ignore SSP
        if (!($spService -is [Microsoft.SharePoint.Administration.SPWebService])) {
            continue;
        }
        # Iterate each web app.
        foreach ($webApp in $spService.WebApplications) {
            # Skip administration sites.
            if ($webApp -is [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]) { continue }
            foreach ($site in $webApp.Sites) {
                if ($site.ID -eq $id) { return $site; }
            }
        }
    }
    return $null;
}

function GetWeb($site, $id) {
    if ($site -eq $null) { return $null; }
    foreach ($web in $site.AllWebs) {
        if ($web.ID -eq $id) { return $web; }
    }
    return $null;
}

function ProcessSetupFile($node) {
    $siteID = $node.SiteID;
    $webID = $node.WebID;
    $listID = $node.ListID;
    if ($siteID -eq $null -or $siteID -eq '') { return; }
    # Get the site instance.    
    $site = GetSite -id $siteID;
    if ($site -eq $null) {
        Write-Host -foregroundcolor Red "Failed to load site with ID $siteID";
    }
    if ($webID -ne $null -or $webID -eq '') {
        $web = GetWeb -site $site -id $webID;
        if ($web -eq $null) { 
            Write-Host -foregroundcolor Red "Failed to load web with ID $webID";
            return;
        }
        Write-Host "Found Web at URL $($web.Url)";
        $node.SetAttribute("WebURL", $web.Url);
        if ($listID -ne $null -and $listID -ne '') {
            $list = $web.Lists[[System.Guid]$listID];
            if ($list -eq $null) {
                Write-Host -foregroundcolor Red "Failed to load list with ID $listID";
            }
            else {
                Write-Host "Found List at URL $($list.DefaultViewUrl)";
                $node.SetAttribute("ListURL", $list.DefaultViewUrl);
            }
        }
    }
    else {
        Write-Host "Found Site at URL $($site.Url)";
        $node.SetAttribute("SiteURL", $site.Url);
    }
}
 
function ProcessAssembly($site, $web, $myArgs) {
    if ($web -eq $null) { return; }
    foreach ($list in $web.Lists) {
        $list.EventReceivers | ? { $_.Assembly -eq $myArgs[0] } | % {
            Write-Host "Found event receiver on list $($list.DefaultViewUrl) for assembly $($myArgs[0])";
            $assemMode = $myArgs[1];
            if ($assemMode.SelectSingleNode("List[@ID='$($list.ID)']") -eq $null) {
                $node = $assemMode.OwnerDocument.CreateElement("List");
                $node.SetAttribute("ID", $list.ID);
                $node.SetAttribute("URL", $list.DefaultViewUrl);
                $assemMode.AppendChild($node) | Out-Null;
            }   
        }
    }
}
 
function ProcessContentDB($node, $name) {
    Write-Host "Processing content DB with name $name";
    $node.MissingFeatures.Feature | % { 
        if ($_ -ne $null) {
            Write-Host "Processing Feature with ID $($_.ID)";
            # Find what site collections and sites the feature is activated.
            IterateFarm -func "ProcessFeature" -myArgs @($_.ID, $_);
        }
    }
    # Find associated workflows
    IterateFarm -func "ProcessWFAssociations" -myArgs $node;
    # Find Missing Setup Files
    $node.MissingSetupFiles.SetupFile | % { ProcessSetupFile -node $_ }
    # Find Missing Web Parts
    $node.MissingWebParts.WebPart | % { ProcessSetupFile -node $_ }
    # Find Assemblies
    $node.MissingAssemblies.Assembly | % {
        Write-Host "Processing Assembly $($_.Name)";
        IterateFarm -func "ProcessAssembly" -myArgs @($_.Name, $_);
    }
}
 
function ProcessScanResults($fname) {
    # Iterate the content DBs in the XML.
    [xml]$data = Get-Content $fname;
    $data.Scan.ContentDBs.ContentDB | % { ProcessContentDB -node $_ -name $_.name }
    $data.Save($fname);
}
 
# Make sure we're running as elevated.
$global:argList = $MyInvocation.BoundParameters.GetEnumerator() | Foreach {"-$($_.Key)", "$($_.Value)"}
$global:argList += $MyInvocation.UnboundArguments
Use-RunAs -additionalArg $global:argList;
try {
    cls;
    ProcessScanResults -fname ($env:dp0 + "\$($profile)_scanresults.xml");
}
catch {
    Write-Host -ForegroundColor Red "Critial Error: " $_.Exception.Message;
}

Read-Host "Done, press enter";


