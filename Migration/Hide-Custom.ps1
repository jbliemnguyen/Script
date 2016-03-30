[CmdletBinding()]
Param([Parameter(Mandatory=$true)][String]$url);

Add-PSSnapin "Microsoft.SharePoint.PowerShell"

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)
$global:totalErrors = 0;
$global:totalUpdates = 0;
$global:totalFieldErrors = 0;

function ProcessWeb($web) {
    #Write-Host -ForegroundColor yellow "Processing Web: $($web.Title)";
    # Look for the pretty URLs list.
    $pul = $web.Lists | ? { $_.Title -eq "Pretty URLs"; }
    if ($pul -ne $null) {
        $pul.Delete();
    }
    
    # Store List IDs to enumerate collection
    $listDict = @{};
    foreach ($list in $web.Lists)
    {
        $listDict.Add($list.Id, $list.Title);        
    }
    $listDict.GetEnumerator() | % {
        $list = $web.Lists[$_.Key];

        # Store field types in array
        $fieldQueryDict = @{};
        $fieldParentDict = @{};    
        $fieldParent2Dict = @{};
        $fieldChildDict = @{};
        $fieldChild2Dict = @{};

        #Write-Host -ForegroundColor DarkMagenta "Processing List: $($list.Title) - ($($list.Fields.Count) total fields) - ($($list.DefaultViewUrl))";        
        
        #Cycle through each field in list
        try { 
            foreach ($field in $list.Fields)
            {
                if ($field.TypeDisplayName -clike "Query*")
                {
                    Write-Host -BackgroundColor Gray -ForegroundColor White "Adding Query Field $($field.Title)"
                    $fieldQueryDict.Add($field.Id, $field.ParentList.Id);                    
                }
                elseif ($field.TypeDisplayName -eq "Parent Drop Down List")
                {
                    Write-Host -BackgroundColor Gray -ForegroundColor White "Adding Parent Field $($field.Title)"
                    $fieldParentDict.Add($field.Id, $field.ParentList.Id); 
                }
                elseif ($field.TypeDisplayName -eq "Parent Drop Down List2")
                {
                    Write-Host -BackgroundColor Gray -ForegroundColor White "Adding Parent2 Field $($field.Title)"
                    $fieldParent2Dict.Add($field.Id, $field.ParentList.Id);
                }
                elseif ($field.TypeDisplayName -eq "Child Drop Down List")
                {
                    Write-Host -BackgroundColor Gray -ForegroundColor White "Adding Child Field $($field.Title)"
                    $fieldChildDict.Add($field.Id, $field.ParentList.Id);
                }
                elseif ($field.TypeDisplayName -eq "Child Drop Down List2")
                {
                    Write-Host -BackgroundColor Gray -ForegroundColor White "Adding Child2 Field $($field.Title)"
                    $fieldChild2Dict.Add($field.Id, $field.ParentList.Id);
                }
                else
                {
                    #Field doesn't match criteria
                }                
            }
            
        }
        catch{
            Write-Host -BackgroundColor red -ForegroundColor White "ERROR Adding Field: $_)";             
            $global:totalFieldErrors = $global:totalFieldErrors + 1;
        }                             

        $fieldQueryDict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Query Field List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            HideFieldInList -field $field -list $flist;
        }
        $fieldParentDict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Parent Field List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            HideFieldInList -field $field -list $flist;
        }
        $fieldParent2Dict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Parent Field2 List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            HideFieldInList -field $field -list $flist;
        }
        $fieldChildDict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Child Field List $($flist.Title) - $($flist.itemcount) Items";        
            $field = $flist.Fields[$_.Name];
            HideFieldInList -field $field -list $flist;
        }
        $fieldChild2Dict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Child Field 2 List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            HideFieldInList -field $field -list $flist;
        }
    }        
}

function HideFieldInList($field, $list)
{               
    $contentTypes = $list.ContentTypes;
    for ($i = 0; $i -lt $contentTypes.Count; $i++)
    {
        try
        { 
            $ct = $contentTypes[$i];
            $fld = $ct.FieldLinks[$field.StaticName];
            if ($fld -ne $null)
            {
                $fld.Hidden = $true;
                write-host "Field $($fld.Name): for list $($ct.ParentList.Title)";    
                $ct.Update();
                $global:totalUpdates = $global:totalUpdates + 1            
            }           
        }     
        catch
        {
            Write-Host -ForegroundColor white -BackgroundColor Red "ERROR Occurred: $_";
            $global:totalErrors = $global:totalErrors + 1
        }
    }        
}

try {
    #Get Start Time
    $startDTM = (Get-Date);
    Set-Location $env:dp0;    
    $siteScope = Start-SPAssignment
    $site = Get-SPSite $url -AssignmentCollection $siteScope
    # Iterate the webs
    $site.AllWebs | % {
        ProcessWeb -web $_;
        if ($_ -ne $null)
        {
            $_.Dispose();
        }
    }
    #ProcessWeb -web (Get-SPWeb "https://test.sp.ferc.gov/teams/SiteDirectory/DCIO/Systems")
    Stop-SPAssignment $siteScope
    Write-Host -ForegroundColor Green "Summary:";
    Write-Host -ForegroundColor Red "$($global:totalErrors) total field update errors";
    Write-Host -ForegroundColor Red "$($global:totalFieldErrors) total field errors";
    Write-Host -ForegroundColor White "$($global:totalUpdates) total updates";    
}
catch {
    Write-Host -ForegroundColor red "Error $($_.Exception)";
}
finally
{
    Stop-SPAssignment $siteScope
    #Get End Time
    $endDTM = (Get-Date)
    #Time Elapsed
    [timespan]$DTS = New-TimeSpan -Start $startDTM -end $endDTM
    $elapsed = "{0:G}" -f $DTS;
    Write-Host -BackgroundColor Blue -ForegroundColor White "$($elapsed) elapsed time";    
      
}