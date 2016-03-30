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
            
                if ($myFields.FormType -ne "Deviation")
                {

                    #Justification
                    if ($myFields.Justification -ne $null -and $myFields.Justification.length -eq 0)
                    {
                        Write-Host "$($Item.File.Name) Is NOT Deviation, Justification is Empty"
                        $myFields.Justification = "N/A"                    
                    }
                    else{
                        if ($myFields.Justification -eq $null)
                        {                
                            Write-Host "$($Item.File.Name) Is NOT Deviation, NO Justification"
                            #$JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                            #$myFields.AppendChild($JustificationElement)
                            #$myFields.Justification = "N/A"                        
                        }
                    }


                    #Risk
                    if ($myFields.Risk -ne $null -and $myFields.Risk.length -eq 0)
                    {
                        Write-Host "$($Item.File.Name) Is NOT Deviation, Risk is Empty"
                        $myFields.Risk = "N/A"                    
                    }
                    else{
                        if ($myFields.Risk -eq $null)
                        {                
                            Write-Host "$($Item.File.Name) Is NOT Deviation, NO Risk"
                            #$JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                            #$myFields.AppendChild($JustificationElement)
                            #$myFields.Justification = "N/A"                        
                        }
                    }

                    #UnmitigateRisk
                    if ($myFields.UnmitigateRisk -ne $null -and $myFields.UnmitigateRisk.length -eq 0)
                    {
                        Write-Host "$($Item.File.Name) Is NOT Deviation, UnmitigateRisk is Empty"
                        $myFields.UnmitigateRisk = "N/A"                    
                    }
                    else{
                        if ($myFields.UnmitigateRisk -eq $null)
                        {                
                            Write-Host "$($Item.File.Name) Is NOT Deviation, NO UnmitigateRisk"
                            #$JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                            #$myFields.AppendChild($JustificationElement)
                            #$myFields.Justification = "N/A"                        
                        }
                    }

                    #Impact
                    if ($myFields.Impact -ne $null -and $myFields.Impact.length -eq 0)
                    {
                        Write-Host "$($Item.File.Name) Is NOT Deviation, Impact is Empty"
                        $myFields.Impact = "N/A"                    
                    }
                    else{
                        if ($myFields.Impact -eq $null)
                        {                
                            Write-Host "$($Item.File.Name) Is NOT Deviation, NO Impact"
                            #$JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                            #$myFields.AppendChild($JustificationElement)
                            #$myFields.Justification = "N/A"                        
                        }
                    }


                    #CompensatingCtrl
                    if ($myFields.CompensatingCtrl -ne $null -and $myFields.CompensatingCtrl.length -eq 0)
                    {
                        Write-Host "$($Item.File.Name) Is NOT Deviation, CompensatingCtrl is Empty"
                        $myFields.CompensatingCtrl = "N/A"                    
                    }
                    else{
                        if ($myFields.CompensatingCtrl -eq $null)
                        {                
                            Write-Host "$($Item.File.Name) Is NOT Deviation, NO CompensatingCtrl"
                            #$JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                            #$myFields.AppendChild($JustificationElement)
                            #$myFields.Justification = "N/A"                        
                        }
                    }


                    #POAM_Remedy
                    if ($myFields.POAM_Remedy -ne $null -and $myFields.POAM_Remedy.length -eq 0)
                    {
                        Write-Host "$($Item.File.Name) Is NOT Deviation, POAM_Remedy is Empty"
                        $myFields.POAM_Remedy = "N/A"                    
                    }
                    else{
                        if ($myFields.POAM_Remedy -eq $null)
                        {                
                            Write-Host "$($Item.File.Name) Is NOT Deviation, NO POAM_Remedy"
                            #$JustificationElement = $xmlfile.CreateElement("my","Justification", $myFieldsNs)
                            #$myFields.AppendChild($JustificationElement)
                            #$myFields.Justification = "N/A"                        
                        }
                    }


                    $savestream = New-Object System.IO.MemoryStream
                    $xmlFile.Save($savestream)
                    $myfile.SaveBinary($savestream.ToArray())
                    $openstream.Close()
                    $savestream.Close()    

                }
            }
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
