[CmdletBinding()]
Param([Parameter(Mandatory=$true)][String]$userName);

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")

$reportFileName = $env:computername + "_" + $userName + ".csv"
Function GetUserAccessReport($SearchUser)
{ 

    #Get SiteCollections for each Web Application
    $siteCollections = [Microsoft.SharePoint.Administration.SPFarm]::local.services | `
	    where-object {$_ -is [Microsoft.SharePoint.Administration.SPWebService] } | `
	    select -expand webapplications | where-object {$_.IsAdministrationWebApplication -ne $true} | select -expand sites

    #Write CSV- TAB Separated File) Header
    "URL `t Site/List `t Title `t PermissionType `t Permissions" | out-file $reportFileName

    #Check Whether the Search Users is a Farm Administrator
    $AdminWebApp = [Microsoft.SharePoint.Administration.SPFarm]::local.services | `
	    where-object {$_ -is [Microsoft.SharePoint.Administration.SPWebService] } | `
	    select -expand webapplications | where-object {$_.IsAdministrationWebApplication -eq $true}

    if ($AdminWebApp.sites.count -gt 0)
    {
        $adminSiteCollection = New-Object Microsoft.SharePoint.SPSite($adminwebapp.sites[0].url)
        $adminSite = $adminSiteCollection.RootWeb
        $AdminGroupName = $AdminSite.AssociatedOwnerGroup
        $FarmAdminGroup = $AdminSite.SiteGroups[$AdminGroupName]

        foreach ($user in $FarmAdminGroup.users)
        {
            if($user.LoginName -like "*" + $SearchUser)
            {
                "$($AdminWebApp.URL) `t Farm `t $($AdminSite.Title)`t Farm Administrator `t Farm Administrator" | Out-File $reportFileName -Append
            }
        }
    }
    

    #Check Web Application Policies
    $WebApps  = [Microsoft.SharePoint.Administration.SPFarm]::local.services | `
	    where-object {$_ -is [Microsoft.SharePoint.Administration.SPWebService] } | `
	    select -expand webapplications

    #Loop through all web apps
    foreach ($webApp in $WebApps)
    {
        foreach ($Policy in $WebApp.Policies)
        {
        #Check if the search users is member of the group
            if($Policy.UserName -like "*" + $SearchUser)
            {
                #Write-Host $Policy.UserName
                $PolicyRoles=@()
                foreach($Role in $Policy.PolicyRoleBindings)
                {
                    $PolicyRoles+= $Role.Name +";"
                }
                #Write-Host "Permissions: " $PolicyRoles

                "$($AdminWebApp.URL) `t Web Application `t $($AdminSite.Title)`t  Web Application Policy `t $($PolicyRoles)" | Out-File $reportFileName -Append
            }
        }
    }

    #Loop through all site collections
    foreach($Site in $SiteCollections)
    {
        #Check Whether the Search User is a Site Collection Administrator
        foreach($SiteCollAdmin in $Site.RootWeb.SiteAdministrators)
        {
            if($SiteCollAdmin.LoginName -like "*" + $SearchUser)
            {
                "$($Site.RootWeb.Url) `t Site `t $($Site.RootWeb.Title)`t Site Collection Administrator `t Site Collection Administrator" | Out-File $reportFileName -Append
            }     
        }
        try
        {
        #Loop through all Sub Sites
        foreach($Web in $Site.AllWebs)
        {
            if($Web.HasUniqueRoleAssignments -eq $True)
                                                                                                                                                                                            {
            #Get all the users granted permissions to the list
            foreach($WebRoleAssignment in $Web.RoleAssignments )
            {
                #Is it a User Account?
                if($WebRoleAssignment.Member.userlogin)   
                {
                    #Is the current user is the user we search for?
                    if($WebRoleAssignment.Member.LoginName -like "*" + $SearchUser)
                    {
                        #Write-Host  $SearchUser has direct permissions to site $Web.Url
                        #Get the Permissions assigned to user
                        $WebUserPermissions=@()
                        foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings)
                        {
                            $WebUserPermissions += $RoleDefinition.Name +";"
                        }
                        #write-host "with these permissions: " $WebUserPermissions
                        #Send the Data to Log file
                        "$($Web.Url) `t Site `t $($Web.Title)`t Direct Permission `t $($WebUserPermissions)" | Out-File $reportFileName -Append
                    }
                }
                #Its a SharePoint Group, So search inside the group and check if the user is member of that group
                else 
                {
                    foreach($user in $WebRoleAssignment.member.users)
                    {
                        #Check if the search users is member of the group
                        if($user.LoginName -like "*" + $SearchUser)
                        {
                            #Write-Host  "$SearchUser is Member of " $WebRoleAssignment.Member.Name "Group"
                            #Get the Group's Permissions on site
                            $WebGroupPermissions=@()
                            foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings)
                            {
                                $WebGroupPermissions += $RoleDefinition.Name +";"
                            }
                            #write-host "Group has these permissions: " $WebGroupPermissions
                            #Send the Data to Log file
                            "$($Web.Url) `t Site `t $($Web.Title)`t Member of $($WebRoleAssignment.Member.Name) Group `t $($WebGroupPermissions)" | Out-File $reportFileName -Append
                        }
                    }
                }
            }
        }
        
            #********  Check Lists with Unique Permissions ********/
            foreach($List in $Web.lists)
                                                                                                                                                                                                    {
            if($List.HasUniqueRoleAssignments -eq $True -and ($List.Hidden -eq $false))
            {
                #Get all the users granted permissions to the list
                foreach($ListRoleAssignment in $List.RoleAssignments )
                {
                    #Is it a User Account?
                    if($ListRoleAssignment.Member.userlogin)   
                    {
                        #Is the current user is the user we search for?
                        if($ListRoleAssignment.Member.LoginName -like "*" + $SearchUser)
                        {
                            #Write-Host  $SearchUser has direct permissions to List ($List.ParentWeb.Url)/($List.RootFolder.Url)
                            #Get the Permissions assigned to user
                            $ListUserPermissions=@()
                            foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings)
                            {
                                $ListUserPermissions += $RoleDefinition.Name +";"
                            }
                            #write-host "with these permissions: " $ListUserPermissions
                            #Send the Data to Log file
                            "$($List.ParentWeb.Url)/$($List.RootFolder.Url) `t List `t $($List.Title)`t Direct Permissions `t $($ListUserPermissions)" | Out-File $reportFileName -Append
                        }
                    }
                    #Its a SharePoint Group, So search inside the group and check if the user is member of that group
                    else 
                    {
                        foreach($user in $ListRoleAssignment.member.users)
                        {
                            if($user.LoginName -like "*" + $SearchUser)
                            {
                                #Write-Host  "$SearchUser is Member of " $ListRoleAssignment.Member.Name "Group"
                                #Get the Group's Permissions on site
                                $ListGroupPermissions=@()
                                foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings)
                                {
                                    $ListGroupPermissions += $RoleDefinition.Name +";"
                                }
                                #write-host "Group has these permissions: " $ListGroupPermissions
                                #Send the Data to Log file
                                "$($Web.Url) `t Site `t $($List.Title)`t Member of $($ListRoleAssignment.Member.Name) Group `t $($ListGroupPermissions)" | Out-File $reportFileName -Append
                            }
                        }
                    }
                }
            }
        }
        }
        }
        catch
        {
            Write-Host -ForegroundColor red "Error in $($Site.url)"
            Write-Host -ForegroundColor DarkRed $_.Exception;
        }
    }
}

#Get Start Time
$startDTM = (Get-Date);

#Call the function to Check User Access
GetUserAccessReport $userName

#Get End Time
$endDTM = (Get-Date)
#Time Elapsed
[timespan]$DTS = New-TimeSpan -Start $startDTM -end $endDTM
$elapsed = "{0:G}" -f $DTS;
Write-Host -BackgroundColor Blue -ForegroundColor White "$($elapsed) elapsed time`r`n"; 