param(
[Parameter(Mandatory=$false)]
#[string]$siteLocation="https://test.sp.ferc.gov/itsecurity/" )
[string]$siteLocation="https://fdc1s-sp23wfed2.ferc.gov/itsecurity/" )

Add-PSSnapin "Microsoft.SharePoint.PowerShell"

$myweb = get-spweb $siteLocation
$myList = $myweb.GetListFromUrl($siteLocation + "Security%20Waiver%20Forms/Forms/AllItems.aspx")

#Get Start Time
$startDTM = (Get-Date);

foreach ($item in $mylist.Items)
{
    # Modify the XML
    try{

        $myfile = $item.File
        if ($myfile -ne $null -and $myfile.name.EndsWith(".xml"))
        {                              
            #only modify XML files
            $xmlFile = New-Object System.Xml.XmlDocument
            $openstream = $myfile.OpenBinaryStream()
            $xmlfile.Load($openstream)        
            $myFields = $xmlfile.myFields
            $myFieldsNs = $myFields.NamespaceURI    

            if ($myFields.FormType -ne $null)
                                                                                            {
            if ($myFields.FormType -eq "Waiver")
            {
                if ($myFields.Justification -ne $null -and $myFields.Justification.length -eq 0)
                {
                    Write-Host "$($Item.File.Name) Is a Waiver without a Justification"
                    $myFields.Justification = "N/A"                    
                }
                else
                {
                    if ($myFields.Justification -eq $null)
                    {                
                        Write-Host "$($Item.File.Name) Is a Waiver without a Justification"
                        $JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                        $myFields.AppendChild($JustificationElement)
                        $myFields.Justification = "N/A"                        
                    }
                }
            
            }
        }
            else
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                {
            Write-Host "$($Item.File.Name) is missing a Form Type"  
            if ($myFields.RequestType -ne $null -and $myFields.RequestType.length -gt 0) {
                if ($myFields.RequestType.Contains("Deviation")) {
                    Write-Host "$($Item.File.Name) seems to be a Deviation"
                    $FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)
                    $myFields.AppendChild($FormTypeElement)
                    $myFields.FormType = "Deviation"                    
                }
                else {
                    if ($myFields.RequestType.Contains("Waiver")) {
                        Write-Host "$($Item.File.Name) seems to be a Waiver"
                        $FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)                    
                        $myFields.AppendChild($FormTypeElement)
                        $myFields.FormType = "Waiver"
                        if ($myFields.Justification -ne $null -and $myFields.Justification.length -eq 0)
                        {
                            Write-Host "$($Item.File.Name) Is a Waiver without a Justification"
                            $myFields.Justification = "N/A"                            
                        }
                        else
                        {
                            if ($myFields.Justification -eq $null)
                            {                
                                Write-Host "$($Item.File.Name) Is a Waiver without a Justification"
                                $JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                                $myFields.AppendChild($JustificationElement)
                                $myFields.Justification = "N/A"                            
                            }
                        }                        
                    }           
                    else {
                        if ($myFields.RequestType.Contains("Extension")) {
                            Write-Host "$($Item.File.Name) seems to be an Extension"
                            $FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)                        
                            $myFields.AppendChild($FormTypeElement)
                            $myFields.FormType = "Extension"
                            if ($myFields.Justification -ne $null -and $myFields.Justification.length -eq 0)
                            {
                                Write-Host "$($Item.File.Name) Is a Extension without a Justification"
                                $myFields.Justification = "N/A"                                
                            }
                            else
                            {
                                if ($myFields.Justification -eq $null)
                                {                
                                    Write-Host "$($Item.File.Name) Is a Extension without a Justification"
                                    $JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                                    $myFields.AppendChild($JustificationElement)
                                    $myFields.Justification = "N/A"                            
                                }
                            }                            
                        }
                    }
                }
            }
            else {
                Write-Host "Request Type is Missing"
                if ($myFields.RequestSubject -ne $null) {
                    if ($myFields.RequestSubject.Contains("Deviation")) {
                        Write-Host "$($Item.File.Name) seems to be a Deviation"
                        $FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)
                        $myFields.AppendChild($FormTypeElement)
                        $myFields.FormType = "Deviation"                        
                    }
                    else {
                        if ($myFields.RequestSubject.Contains("Waiver")) {
                            Write-Host "$($Item.File.Name) seems to be a Waiver"
                            $FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)                        
                            $myFields.AppendChild($FormTypeElement)
                            $myFields.FormType = "Waiver"
                            if ($myFields.Justification -ne $null -and $myFields.Justification.length -eq 0)
                            {
                                Write-Host "$($Item.File.Name) Is a Waiver without a Justification"
                                $myFields.Justification = "N/A"                                
                            }
                            else
                            {
                                if ($myFields.Justification -eq $null)
                                {                
                                    Write-Host "$($Item.File.Name) Is a Waiver without a Justification"
                                    $JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                                    $myFields.AppendChild($JustificationElement)
                                    $myFields.Justification = "N/A"                            
                                }
                            }                            
                        }           
                        else {
                            if ($myFields.RequestSubject.Contains("Extension")) {
                                Write-Host "$($Item.File.Name) seems to be an Extension"
                                $FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)                            
                                $myFields.AppendChild($FormTypeElement)
                                $myFields.FormType = "Extension"
                                if ($myFields.Justification -ne $null -and $myFields.Justification.length -eq 0)
                                {
                                    Write-Host "$($Item.File.Name) Is an Extension without a Justification"
                                    $myFields.Justification = "N/A"                                    
                                }
                                else
                                {
                                    if ($myFields.Justification -eq $null)
                                    {                
                                        Write-Host "$($Item.File.Name) Is an Extension without a Justification"
                                        $JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                                        $myFields.AppendChild($JustificationElement)
                                        $myFields.Justification = "N/A"                            
                                    }
                                }                                
                            }
                        }
                    }
                }
            }

        }
        
            $savestream = New-Object System.IO.MemoryStream
            $xmlFile.Save($savestream)
            $myfile.SaveBinary($savestream.ToArray())
            $openstream.Close()
            $savestream.Close()      
        }
                
    }
    catch
    {
        Write-Host -ForegroundColor red "Error $($_.Exception)";
    }

}

# Get list again since the file may have been updated
$myList = $myweb.GetListFromUrl($siteLocation + "Security%20Waiver%20Forms/Forms/AllItems.aspx")
foreach ($item in $mylist.Items)
{
    # Modify if file title is incorrect
    try{        
        if ($item.Name -cne $item.Title)
        {
            Write-Host("$($item.Name) -NE $($item.Title)")
            $item.Properties["vti_title"] = $item.Name         
            $item.SystemUpdate()
        }
    }
    catch
    {
        Write-Host -ForegroundColor red "Error $($_.Exception)";
    }
}

#Get End Time
$endDTM = (Get-Date)
#Time Elapsed
[timespan]$DTS = New-TimeSpan -Start $startDTM -end $endDTM
$elapsed = "{0:G}" -f $DTS;
Write-Host -BackgroundColor Blue -ForegroundColor White "$($elapsed) elapsed time";  

<#
# TEST WITHOUT A FILE

$myweb = get-spweb "https://test.sp.ferc.gov/itsecurity/"
$myList = $myweb.GetListFromUrl("https://test.sp.ferc.gov/itsecurity/Security%20Waiver%20Forms/Forms/AllItems.aspx")
$myitem = $mylist.GetItemById(3)
$myfile = $myitem.File

#$filedata = $myfile.OpenBinary()
#$encode = New-Object System.Text.UTF8Encoding
#$xmlFile = [xml]($encode.GetString($filedata))
$xmlFile = New-Object System.Xml.XmlDocument
$openstream = $myfile.OpenBinaryStream()
$xmlfile.Load($openstream)

$myFields = $xmlfile.myFields
$myFieldsNs = $myFields.NamespaceURI
$FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)
$myFields.AppendChild($FormTypeElement)
$myFields.FormType = "Deviation"

#$stream = New-Object System.IO.MemoryStream
#$xmlFile.Save($stream)
#$myfile.SaveBinary($stream.ToArray())

$closestream = New-Object System.IO.MemoryStream
$xmlFile.Save($closestream)
$myfile.SaveBinary($closestream.ToArray())


# TEST WITH A FILE

$myweb = get-spweb "https://test.sp.ferc.gov/itsecurity/"
$myList = $myweb.GetListFromUrl("https://test.sp.ferc.gov/itsecurity/Security%20Waiver%20Forms/Forms/AllItems.aspx")
$myitem = $mylist.GetItemById(39)
$myfile = $myitem.File

#$filedata = $myfile.OpenBinary()
#$encode = New-Object System.Text.UTF8Encoding
#$xmlFile = [xml]($encode.GetString($filedata))
$xmlFile = New-Object System.Xml.XmlDocument
$openstream = $myfile.OpenBinaryStream()
$xmlfile.Load($openstream)

$myFields = $xmlfile.myFields
$myFieldsNs = $myFields.NamespaceURI
$FormTypeElement = $xmlfile.CreateElement("my","FormType", $myFieldsNs)
$myFields.AppendChild($FormTypeElement)
$myFields.FormType = "Deviation"

#$stream = New-Object System.IO.MemoryStream
#$xmlFile.Save($stream)
#$myfile.SaveBinary($stream.ToArray())

$closestream = New-Object System.IO.MemoryStream
$xmlFile.Save($closestream)
$myfile.SaveBinary($closestream.ToArray())

#>