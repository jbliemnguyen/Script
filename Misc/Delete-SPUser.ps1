[CmdletBinding()]
Param([Parameter(Mandatory=$true)][String]$userLogin,[Switch] $delete, [Switch] $showUsers);

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

$0 = $myInvocation.MyCommand.Definition
$global:totalErrors = 0
$global:totalUsers = 0
$global:totalDeletesFound = 0
$global:totalDeleted = 0
$global:totalSites = 0
$transcriptFileName = $pwd.path + "\" + $env:computername + "_" + $userLogin + ".txt"

# Notify user that they are going to be DELETING users
if ($delete)
{
    Start-Transcript $transcriptFileName
    $message  = 'You are in DELETE Mode'
    $question = 'Are you sure you want to proceed?'

    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'Delete-SPUser processing...'
    } else {
        Write-Host 'Delete-SPUser has been aborted.'
        Stop-Transcript;
        Break;
    }
}

#Continue if non-delete mode or if allowed by selection
try {            
    
    #Get Start Time
    $startDTM = (Get-Date);

    #Get SiteCollections for each Web Application
    $siteCollections = [Microsoft.SharePoint.Administration.SPFarm]::local.services | `
	    where-object {$_ -is [Microsoft.SharePoint.Administration.SPWebService] } | `
	    select -expand webapplications | where-object {$_.IsAdministrationWebApplication -ne $true} | select -expand sites

    #Iterate Site Collections
    foreach ($site in $siteCollections)
    {
        Write-Host "`t Site Collection: " $site.Url "`r`n"
        $global:totalSites++
        $users = $site.RootWeb.SiteUsers
	    $global:totalUsers += $users.count

        #Display all users if flag is set
        if ($showUsers)
        {
            Write-Host "`t`t" -NoNewline
            foreach ($u in $users){
                Write-Host $u.loginName ";" -NoNewline -ForegroundColor Gray
            }
            Write-Host "`r`n"
        }

        #Match collection of users
        $user = $users | ? {$_.loginName -like "*" + $userLogin}

        if ($user -ne $null)
        {
            #Iterate collection (if multiple users that match login)
            foreach ($u in $user)
            {
                write-host "`t`t (" $u.loginName ")`r`n" -ForegroundColor yellow                    
                $global:totalDeletesFound++

                #Only delete if in delete mode
                if ($delete)
                {
                    $site.RootWeb.SiteUsers.Remove($u)
                    $global:totalDeleted++
                }
            }
        }
        $site.Dispose();
    }

    Write-Host -ForegroundColor Green "Summary:`r`n";
    Write-Host -ForegroundColor White "$($global:totalSites) total Sites`r`n";
    Write-Host -ForegroundColor White "$($global:totalUsers) total Users checked`r`n";
    Write-Host -ForegroundColor Red "$($global:totalErrors) total errors`r`n";
    Write-Host -ForegroundColor Yellow "$($global:totalDeletesFound) total deletes found`r`n";   
    
    if (!$delete)
    {
        Write-Host -backgroundcolor red -ForegroundColor white "Re-run Delete-SPUser with -delete flag to delete users.`r`n"
    }
    else
    {
        Write-Host -backgroundcolor red -ForegroundColor white "$($global:totalDeleted) total deleted`r`n";
    }
}

catch {
    Write-Host -ForegroundColor red "Error $($_.Exception)";
}

finally
{ 
    #Get End Time
    $endDTM = (Get-Date)
    #Time Elapsed
    [timespan]$DTS = New-TimeSpan -Start $startDTM -end $endDTM
    $elapsed = "{0:G}" -f $DTS;
    Write-Host -BackgroundColor Blue -ForegroundColor White "$($elapsed) elapsed time`r`n";  
    if ($delete)
    {
        stop-transcript    
    }
}