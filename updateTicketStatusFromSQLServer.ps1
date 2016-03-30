Add-PSSnapin "Microsoft.SharePoint.PowerShell"

function Invoke-SQL {
    param(
        [string] $dataSource,
        [string] $database,
        # [string] $sqlCommand = $(throw "Please specify a query.")
		[string] $sqlCommand
      )

    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    
	$result = @{}
	
	foreach ($row in $dataSet.Tables.Rows)
	{
		$result[$row["incident_number"]] = $row["status_str"]		
	}
	
	return $result;

}

function generateQueryCommand{
	param(
[string[]] $incidents

	)
	
	$query = @"
	SELECT  hd.incident_number,
					CASE 		
						when hd.status = 1 then 'Assigned'
						when hd.status = 2 then 'In Progress'
						when hd.status = 3 then 'Pending'
						when hd.status = 4 then 'Resolved'
						when hd.status = 5 then 'Closed'
						when hd.status = 6 then 'Cancelled'
						else 'Unknown Status'
						end as status_str
				FROM HPD_Help_Desk hd
				WHERE assigned_support_company = 'IT Contract Support'
				And incident_number in (
"@			
	
	
	for ($i=0; $i -lt $incidents.length; $i++) {
		if ($i -eq 0){
			$query = $query + "'" + $incidents[$i] + "'"
		}else{
			$query = $query + ",'" + $incidents[$i] + "'"
		}
}
	
	$query = $query + ")";
	
	return $query;
}



# ****************** Main ******************

try{

$webURL = "https://sp.ferc.gov/sites/LiemDev"
$myweb = get-spweb $webURL

$myList = $myweb.GetListFromUrl($webURL + "/TEST_ECT/Forms/AllItems.aspx")

$incidents = New-Object System.Collections.ArrayList


#populate list of incident ticket
foreach ($item in $mylist.Items)
{
    # Modify the XML
    
        $myfile = $item.File
        if ($myfile -ne $null -and $myfile.name.EndsWith(".xml"))
        {                              
            #only modify XML files
            $xmlFile = New-Object System.Xml.XmlDocument
            $openstream = $myfile.OpenBinaryStream()
            $xmlfile.Load($openstream)        
            $myFields = $xmlfile.myFields
            $myFieldsNs = $myFields.NamespaceURI
            
            
            if ($myFields.remedy_ticketNumber){
                $incidents.Add($myFields.remedy_ticketNumber);               
                
            }
            
            
            if ($openstream)
            {
                $openstream.Close()
            }
            #$savestream.Close()   
            
        }
    
}

#Write-Host "Finish generate Array List:"
#$incidents
$query = generateQueryCommand $incidents

#query the db to get the ticket status, return value is dictionary of ticket and status
$incidentStatusList = Invoke-SQL "FDC1S-itsmdbp2" "ARSystem7604" $query


#Set the status
foreach ($item in $mylist.Items)
{
    
        $myfile = $item.File
        if ($myfile -ne $null -and $myfile.name.EndsWith(".xml"))
        {                              
            #only modify XML files
            $xmlFile = New-Object System.Xml.XmlDocument
            $openstream = $myfile.OpenBinaryStream()
            $xmlfile.Load($openstream)        
            $myFields = $xmlfile.myFields
            $myFieldsNs = $myFields.NamespaceURI
            
            
            if ($myFields.remedy_ticketNumber)
            {

                $save = $false;
                if (!$myFields.remedy_ticketStatus)
                {
                    $save = $true;
                }
                else
                {
                    if ($incidentStatusList[$myFields.remedy_ticketNumber] -ne $myFields.remedy_ticketStatus)
                    {
                        $save = $true;
                    }
                }

                if ($save)
                {
                    $myFields.remedy_ticketStatus = $incidentStatusList[$myFields.remedy_ticketNumber];#set the status
                    #save and close file
                    $savestream = New-Object System.IO.MemoryStream
                    $xmlFile.Save($savestream)
                    $myfile.SaveBinary($savestream.ToArray())
                }


                
            }
            
            if ($openstream)
            {
                $openstream.Close()
            }

            if ($savestream)
            {
                $savestream.Close()   
            }
            
        }
    
}

}
catch
{
    Write-Host -ForegroundColor red "Error $($_.Exception)";    
    $date = Get-Date -Format "MM_dd_yyyy_h_mm_ss";    
    $exceptionFilePath = $date + ".txt";         
    $_.Exception | Out-File $exceptionFilePath
}
finally
{
        
}

# $incidents = @("INC000000142290", "INC000000157392", "INC000000198907");
# $query = generateQueryCommand $incidents

# Invoke-SQL "FDC1S-itsmdbp2" "ARSystem7604" $query














