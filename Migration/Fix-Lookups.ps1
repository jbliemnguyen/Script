[CmdletBinding()]
Param([Parameter(Mandatory=$true)][String]$url);

Add-PSSnapin "Microsoft.SharePoint.PowerShell"

$0 = $myInvocation.MyCommand.Definition
$env:dp0 = [System.IO.Path]::GetDirectoryName($0)
$global:totalErrors = 0
$global:totalUpdates = 0
$global:totalEmptyLookups = 0
$global:totalNonItems = 0
$global:totalViewFieldsUpdated = 0
$global:totalGroupByFieldsUpdated = 0
$global:totalViewFieldErrors = 0
$global:totalGroupByFieldErrors = 0


#Lookup the ID based on Title.  Additional Specific use case for multiple lookups based on the System Field and default first find for others
function GetItemIdFromTitle([string]$LookupTitle, [ref]$LookupId, $origItem, $parentList)
 { 
 $LookupItem = $parentList.Items | Where-Object {$_.Title -eq $LookupTitle}
 if ($LookupItem.count -gt 1)
 {    
    $replacedLookupItem = $LookupItem | ? {$_["System"] -match $origItem["System"]}    
    if ($replacedLookupItem -ne $null)
    {
        $lookupItem = $replacedLookupItem;
    }
    else
    {
        #set the first instance
        $lookupItem = $lookupItem[0];
    }
 }
 if ($lookupItem.count -eq 0)
 {
    $lookupItem = $parentList.Items | Where-Object {$_.Name -eq $lookupTitle}    
 }
 $LookupId.Value = $LookupItem.ID
 }

#IterateThroughItemsAndRepopulate
function RePopulateListItems($docLib, $origFieldName, $newFieldName, $parentList)
{
    $itemArray = $docLib.Items
    $updatedItems = 0
    $nonItems = 0
    $errorItems = 0
    $emptyLookups = 0
    Write-Host -ForegroundColor Cyan "Repopulating field $origFieldName values into $newFieldName for $($docLib.Title) ($($itemarray.count) items)"; 
    foreach ($item in $itemArray)
    {    
        if ($item[$origFieldName])
        {
            $LookupIdValue = "0"
            $refLookupValue = "";
            GetItemIdFromTitle -lookupTitle $item[$origFieldName] -LookupId ([ref]$LookupIdValue) -origItem $item -parentList $parentList
            try
            {
                $newLookupValue = New-Object Microsoft.SharePoint.SPFieldLookupValue($LookupIdValue, $item[$origFieldName])                
                if ($VerbosePreference -ne "SilentlyContinue")
                {
                    Write-Host -ForegroundColor DarkGray "O:$($item[$origFieldName]),N:$($newLookupValue);"
                }
                if ($LookupIdValue -eq "0")
                {
                    $emptyLookups++
                }
                $item[$newFieldName] = $newLookupValue
                $item.SystemUpdate()
                $updatedItems++
            }
            catch
            {
                Write-Host -ForegroundColor white -BackgroundColor Red "ERROR Occurred: $_";                
                $errorItems++
            }                  
            
        }
        else
        {
            $nonItems++
        }    
    }
    if ($updatedItems -gt 0)
    {
        Write-host -ForegroundColor white -BackgroundColor darkgreen "$updatedItems lookup values were updated"; 
    }
    if ($emptyLookups -gt 0)
    {
        Write-Host -ForegroundColor white -BackgroundColor DarkYellow "$emptyLookups empty lookup values were found";
    }
    if ($errorItems -gt 0)
    {
        Write-Host -ForegroundColor White -BackgroundColor red "$errorItems errors";
    }
    
    $global:totalErrors = $global:totalErrors + $errorItems
    $global:totalUpdates = $global:totalUpdates + $updatedItems
    $global:totalEmptyLookups = $global:totalEmptyLookups + $emptyLookups
    $global:totalNonItems = $global:totalNonItems + $nonItems
}


function ProcessWeb($web) {
    Write-Host -ForegroundColor yellow "Processing Web: $($web.Title)";
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

        Write-Host -ForegroundColor DarkMagenta "Processing List: $($list.Title) - ($($list.Fields.Count) total fields) - ($($list.DefaultViewUrl))";        
        
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
             Write-Host -BackgroundColor red -ForegroundColor White "ERROR Adding Field: $_)"
        }                             

        $fieldQueryDict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Query Field List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            ProcessQueryFieldInList -field $field -list $flist;
        }
        $fieldParentDict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Parent Field List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            ProcessParentFieldInList -field $field -list $flist;
        }
        $fieldParent2Dict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Parent Field2 List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            ProcessParent2FieldInList -field $field -list $flist;
        }
        $fieldChildDict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Child Field List $($flist.Title) - $($flist.itemcount) Items";        
            $field = $flist.Fields[$_.Name];
            ProcessChildFieldInList -field $field -list $flist;
        }
        $fieldChild2Dict.GetEnumerator() | % { 
            $flist = $web.Lists[$_.Value];
            Write-Host -ForegroundColor White "Processing Child Field 2 List $($flist.Title) - $($flist.itemcount) Items";
            $field = $flist.Fields[$_.Name];
            ProcessChild2FieldInList -field $field -list $flist;
        }
    }        
}

function ProcessQueryFieldInList($field, $list) {
    $originalHost = "http://share.ferc.gov"
    $xml = [xml]$field.SchemaXml;
    $properties = $xml.Field.Customization.ArrayOfProperty.Property;
    $lookupSiteUrl = $properties | ? { $_.Name -eq "SiteUrl" } | % { $_.Value.InnerText };
    $lookupSiteUrl = $lookupSiteUrl.toLower();
    $lookupListName = $properties | ? { $_.Name -eq "LookUpListName" } | % { $_.Value.InnerText };
    $lookupListName = $lookupListName.toLower();
    $lookUpDisplayColumnText = $properties | ? { $_.Name -eq "LookUpDisplayColumnText" } | % { $_.Value.InnerText }; 
    $lookUpDisplayColumnText = $lookUpDisplayColumnText.toLower();
    $lookupSiteUrl = $lookupSiteUrl.Replace($originalHost, "");
    # Get the lookup field.
    $lookupListUrl = $lookupListName.replace($lookupSiteUrl, "");
    $lookupWeb = Get-SPWeb $list.ParentWeb.Url        
    $lookupListUrl = "$($lookupWeb.Url)$lookupListUrl";
    $lookupList = $lookupWeb.GetList($lookupListUrl);
    $newFieldName = "New$($field.Title)";
    
    CreateLookupInList -list $list -fieldName $newFieldName -lookupList $lookupList -lookupFieldName "Title" -origFieldName $Field.Title;
}

function ProcessParentFieldInList($field, $list) {
    $originalHost = "http://share.ferc.gov"
    $xml = [xml]$field.SchemaXml;
    $properties = $xml.Field.Customization.ArrayOfProperty.Property;
    $lookupSiteUrl = $properties | ? { $_.Name -eq "ParentSiteUrl" } | % { $_.Value.InnerText };    
    $lookupSiteUrl = $lookupSiteUrl.toLower();
    $lookupSiteUrl = $lookupSiteUrl.Replace($originalHost, "");
    $lookupListName = $properties | ? { $_.Name -eq "ParentListName" } | % { $_.Value.InnerText };
    $lookUpDisplayColumnText = $properties | ? { $_.Name -eq "ParentListTextField" } | % { $_.Value.InnerText };     
    # Get the lookup field.
    $lookupSiteUrl = "$($list.parentweb.site.url)$lookupsiteurl";
    # Outlier field fix for Systems
    if ($list.Title -eq "IT PARC Project Library")
    {
        $lookupListName = $lookuplistName.Replace("EA Projects List", "EA Systems")
    }
    $lookuplisturl = "$($list.ParentWeb.site.url)$lookuplistname"
    $lookupWeb = Get-SPWeb $lookupsiteurl
    $lookuplist = $lookupweb.getlistfromurl($lookuplisturl)
    $newFieldName = "New$($field.Title)";
    
    CreateLookupInList -list $list -fieldName $newFieldName -lookupList $lookupList -lookupFieldName "Title" -origFieldName $Field.Title;
}

function ProcessParent2FieldInList($field, $list) {
    $originalHost = "http://share.ferc.gov"
    $xml = [xml]$field.SchemaXml;
    $properties = $xml.Field.Customization.ArrayOfProperty.Property;
    $lookupSiteUrl = $properties | ? { $_.Name -eq "ParentSiteUrl" } | % { $_.Value.InnerText };    
    $lookupSiteUrl = $lookupSiteUrl.toLower();
    $lookupSiteUrl = $lookupSiteUrl.Replace($originalHost, "");
    $lookupListName = $properties | ? { $_.Name -eq "ParentListName" } | % { $_.Value.InnerText };
    $lookUpDisplayColumnText = $properties | ? { $_.Name -eq "ParentListTextField" } | % { $_.Value.InnerText };     
    # Get the lookup field.
    $lookupSiteUrl = "$($list.parentweb.site.url)$lookupsiteurl";
    # Exclusion for DEV Testing
    if ($lookupSiteUrl.Contains("http://fdc1s-sp23wfed1"))
    {
        $lookupsiteurl = $lookupsiteurl.Replace("sitedirectory/dcio/systems","")
    }
    $lookupWeb = Get-SPWeb $lookupsiteurl
    $lookupList = $lookupWeb.lists[$lookupListName];
    $newFieldName = "New$($field.Title)";
    
    CreateLookupInList -list $list -fieldName $newFieldName -lookupList $lookupList -lookupFieldName "Title" -origFieldName $Field.Title;
}

function ProcessChildFieldInList($field, $list) {
    $originalHost = "http://share.ferc.gov"
    $xml = [xml]$field.SchemaXml;
    $properties = $xml.Field.Customization.ArrayOfProperty.Property;
    $lookupSiteUrl = $properties | ? { $_.Name -eq "ChildSiteUrl" } | % { $_.Value.InnerText };    
    $lookupSiteUrl = $lookupSiteUrl.toLower();
    $lookupSiteUrl = $lookupSiteUrl.Replace($originalHost, "");    
    $lookupsiteurl = $lookupsiteurl.replace("/_layouts/viewlsts.aspx","")
    $lookupListName = $properties | ? { $_.Name -eq "ChildListName" } | % { $_.Value.InnerText };        
    $lookUpDisplayColumnText = $properties | ? { $_.Name -eq "ChildListTextField" } | % { $_.Value.InnerText };     
    # Get the lookup field.
    $lookupsiteurl = "$($list.ParentWeb.site.url)$lookupSiteUrl"          
    $lookuplisturl = "$($list.ParentWeb.site.url)$lookuplistname"
    $lookupWeb = Get-SPWeb $lookupsiteurl      
    $lookupList = $lookupweb.getlistfromurl($lookuplisturl)
    $newFieldName = "New$($field.Title)";
    
    CreateLookupInList -list $list -fieldName $newFieldName -lookupList $lookupList -lookupFieldName "Title" -origFieldName $Field.Title;
}

function ProcessChild2FieldInList($field, $list) {
    $originalHost = "http://share.ferc.gov"
    $xml = [xml]$field.SchemaXml;
    $properties = $xml.Field.Customization.ArrayOfProperty.Property;
    $lookupSiteUrl = $properties | ? { $_.Name -eq "ChildSiteUrl" } | % { $_.Value.InnerText };    
    $lookupSiteUrl = $lookupSiteUrl.toLower();
    $lookupSiteUrl = $lookupSiteUrl.Replace($originalHost, "");
    $lookupListName = $properties | ? { $_.Name -eq "ChildListName" } | % { $_.Value.InnerText };    
    if ($lookupListName.toLower() -eq "project process area")
    {
        $lookuplistName = "ProjectProcessArea";
    }
    $lookUpDisplayColumnText = $properties | ? { $_.Name -eq "ChildListTextField" } | % { $_.Value.InnerText };     
    # Get the lookup field.  
    $lookupSiteUrl = "$($list.parentweb.site.url)$lookupsiteurl";
    # Exclusion for DEV Testing
    if ($lookupSiteUrl.Contains("http://fdc1s-sp23wfed1"))
    {
        $lookupsiteurl = $lookupsiteurl.Replace("sitedirectory/dcio/systems","")
    }
    $lookupWeb = Get-SPWeb $lookupsiteurl      
    $lookupList = $lookupWeb.lists[$lookupListName];
    $newFieldName = "New$($field.Title)";
    
    CreateLookupInList -list $list -fieldName $newFieldName -lookupList $lookupList -lookupFieldName "Title" -origFieldName $Field.Title;
}



function CreateLookupInList($list, $fieldName, $lookupList, $lookupFieldName, $origFieldName) {
    $existing = $list.Fields[$fieldName];
    if ($existing -ne $null) {
        Write-Host -ForegroundColor White -BackgroundColor Red "Lookup field '$($fieldName)' already exists-BYPASSING Creation"    
    }
    else
    {
        Write-Host -ForegroundColor DarkGray "Creating lookup field '$($fieldName)' to replace '$($origFieldName)' with lookuplist '$($lookupList.Title)'"    
    
        $list.Fields.AddLookup($fieldName, $lookupList.Id ,"true") | Out-Null;
        $existing = $list.Fields[$fieldName];
        if ($existing -eq $null) { throw "Failed to find list just created"; }
        if ($lookupFieldName -ne "Title")
        {
            write-host "Lookupfield Name not Title"
            return;
        }

        #outlying use case of an incorrect lookup field name for list
        if ($lookuplist.Title -eq "BusinessProcessLinks")
        {
	        $lookupFieldName = "Tiltle";
        }

        $existing.LookupField = $lookupList.Fields[$lookupFieldName];
        $existing.Required = $false;    
        $existing.Update();
    }
    RePopulateListItems -docLib $list -origFieldName $origFieldName -newFieldName $fieldName -parentList $lookupList
    ReconfigureViews -docLib $list -origField $list.Fields[$origFieldName] -newField $existing
    #Rename Field to original name
    $existing.Title = $origFieldName
    $existing.update();
} 

function ReconfigureViews($docLib, $origField, $newField)
{
    $viewDispDict = @{};
    $viewGroupDict = @{};
    $views = $docLib.views
    Write-Host -ForegroundColor White "Reconfiguring views for $($docLib.Title) - ($($views.Count) total Views) - $($docLib.DefaultViewUrl)"
    foreach ($view in $views)
    {
        $viewXml = [xml]$view.SchemaXml;
        if ($view.ViewFields -contains $origField.StaticName)
        {
            $viewDispDict.Add($view.ID, $view.Url);
        }
        if ($viewXml.View.Query.GroupBy.FieldRef.Name -contains $origField.StaticName)
        {
            $viewGroupDict.Add($view.ID, $view.Url);
        }
    }

    $viewDispDict.GetEnumerator() | % { 
        $view = $docLib.Views[$_.Key];
        $view.ViewFields.Delete($origField.StaticName);
        $view.ViewFields.Add($newField);
        try
        {
            Write-Host -ForegroundColor Cyan "Removing DisplayField $($origField.StaticName) field and adding $($newField.StaticName) field to View $($view.ID)"
            $view.Update();
            $global:totalViewFieldsUpdated++;
        }
        catch
        {
            Write-Host -ForegroundColor white -BackgroundColor Red "ERROR Occurred Updating ViewField: $_";                
            $global:totalViewFieldErrors++;
        }
    }
    $viewGroupDict.GetEnumerator() | % { 
        $view = $docLib.Views[$_.Key];
        $query = $view.Query;
        if ($query.Contains($origField.StaticName))
        {
            $view.Query = $query.Replace($origField.StaticName, $newField.StaticName);
            try
            {
                Write-Host -ForegroundColor DarkCyan "Removing GroupBy $($origField.StaticName) field and adding $($newField.StaticName) field to View $($view.ID)"
                $view.Update();
                $global:totalGroupByFieldsUpdated++;
            }
            catch
            {
                Write-Host -ForegroundColor white -BackgroundColor Red "ERROR Occurred Updating ViewField: $_";                
                $global:totalGroupByFieldErrors++;
            }
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
    ##ProcessWeb -web (Get-SPWeb "https://test.sp.ferc.gov/teams/SiteDirectory/DCIO/Systems")
    Stop-SPAssignment $siteScope
    Write-Host -ForegroundColor Green "Summary:";
    Write-Host -ForegroundColor Red "$($global:totalErrors) total value update errors";
    Write-Host -ForegroundColor White "$($global:totalUpdates) total updates";
    Write-Host -ForegroundColor DarkGray "$($global:totalEmptyLookups) total empty lookups";
    Write-Host -ForegroundColor Gray "$($global:totalNonItems) total non items";
    Write-Host -ForegroundColor Red "$($global:totalViewFieldErrors) total ViewField errors";
    Write-Host -ForegroundColor Yellow "$($global:totalViewFieldsUpdated) total ViewFields updated";
    Write-Host -ForegroundColor Red "$($global:totalGroupByFieldErrors) total GroupBy Field Errors";
    Write-Host -ForegroundColor Yellow "$($global:totalGroupByFieldsUpdated) total GroupBy Fields updated";
    
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