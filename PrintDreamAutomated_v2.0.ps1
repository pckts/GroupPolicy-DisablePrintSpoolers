#Created by packet

#Checks if run as admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
    cls
    write-host "Please run as admin..."
    sleep 1
    break
}

#Sets the TLS settings to allow downloads via HTTP
#Downloads, installs, and imports neccesary modules
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = "SilentlyContinue"
import-module activedirectory | out-null
install-module Microsoft.powershell.archive | out-null
import-module Microsoft.powershell.archive | out-null
cls

#Shows the startup banner main menu.
$banner = 
{
    sleep 1
    cls
    write-host "";
    write-host "                                      " -BackGroundColor Black -NoNewLine; write-host "By packet" -ForeGroundColor Red -BackGroundColor Black -NoNewLine; write-host "                                      " -BackGroundColor Black
    write-host "  " -BackGroundColor Black -NoNewLine; write-host "██████╗ ██████╗ ██╗███╗   ██╗████████╗██████╗ ██████╗ ███████╗ █████╗ ███╗   ███╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
    write-host "  " -BackGroundColor Black -NoNewLine; write-host "██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗ ████║" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
    write-host "  " -BackGroundColor Black -NoNewLine; write-host "██████╔╝██████╔╝██║██╔██╗ ██║   ██║   ██║  ██║██████╔╝█████╗  ███████║██╔████╔██║" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
    write-host "  " -BackGroundColor Black -NoNewLine; write-host "██╔═══╝ ██╔══██╗██║██║╚██╗██║   ██║   ██║  ██║██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
    write-host "  " -BackGroundColor Black -NoNewLine; write-host "██║     ██║  ██║██║██║ ╚████║   ██║   ██████╔╝██║  ██║███████╗██║  ██║██║ ╚═╝ ██║" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
    write-host "  " -BackGroundColor Black -NoNewLine; write-host "╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "  " -BackGroundColor Black
    write-host "                                                                                     " -BackGroundColor Black
    write-host "+---FUNCTIONS------------------------+" -BackGroundColor Black -NoNewLine; write-host "---README-------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|1. (deploy) Rolls back workarounds  |" -BackGroundColor Black -NoNewLine; write-host " This script is used to roll back workarounds |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|and deploys chosen remediation GPO  |" -BackGroundColor Black -NoNewLine; write-host " deployed with PrintNightmareAutomated or     |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|------------------------------------|" -BackGroundColor Black -NoNewLine; write-host " deployments that otherwise follow the same   |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|2. (cleanup) Deletes previously     |" -BackGroundColor Black -NoNewLine; write-host " naming conventions.                          |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|delpoyed remediation GPOs           |" -BackGroundColor Black -NoNewLine; write-host " (CTRL+C to exit)       For INTERNAL use only |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "+------------------------------------+" -BackGroundColor Black -NoNewLine; write-host "----------------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host ""
    $WantedFunction = read-host "Select function (1/2)"
    
    #If neither 1 or 2 is selected, user is forced to stay on main menu
    if ($WantedFunction -ne "1" -and $WantedFunction -ne "2")
    {
        &@banner
    }
    #If function 2 is selected, GPO from previous deployment(s) are detected and deleted, user is then returned to main menu.
    if ($WantedFunction -eq "2")
    {
        $PreviousGPOs = Get-GPO -All | Where-Object {$_.displayname -like "PRTNMITR_*"}
        foreach ($PreviousGPO in $PreviousGPOs)
        {
            $PGPO = $PreviousGPO.Displayname
            Remove-GPO -Name $PGPO
        }
        cls
        write-host "CLEANUP COMPLETE" -ForegroundColor Green
        sleep 1
        &@banner
    }
}
&@banner
$bannerexit

#Detects if GPO(s) stemming from a previous run of this script exists. If it does, it will warn the user and refuse to continue.
#It will display a warning message and then after acknowledgement from the user, return them to the main menu.
$HasRunBefore = Get-GPO -All | Where-Object {$_.displayname -like "PRTNMITR_*"}
if ($HasRunBefore -ne $null)
{
    sleep 1
    cls
    write-host ""
    write-host "===" -ForegroundColor DarkGray -NoNewLine; write-host "ERROR" -ForegroundColor Red -NoNewLine; write-host "===" -ForegroundColor DarkGray -NoNewLine; write-host "ERROR" -ForegroundColor Red -NoNewLine; write-host "===" -ForegroundColor DarkGray -NoNewLine; write-host "ERROR" -ForegroundColor Red -NoNewLine; write-host "===" -ForegroundColor DarkGray -NoNewLine; write-host "ERROR" -ForegroundColor Red -NoNewLine; write-host "===" -ForegroundColor DarkGray;
    write-host ""
    write-host "A previous run of the script has been detected!" 
    write-host "You can not proceed until you've run a cleanup."
    write-host ""
    pause
    &@banner
}

#Detects and deletes all GPOs stemming from workaround deployments with PrintNightmareAutomated as well as most manual deployments.
#It will display the list to the user and ask for them to verify, to ensure no production GPOs are affected.
#If no GPOs are detected, it will simply proceed without deleting anything. (After telling the user briefly)
$SpoolerGPOs = Get-GPO -All | Where-Object {$_.displayname -like "*spool*" -or $_.displayname -like "*nightmare*"} | Select displayname
if ($SpoolerGPOs -ne $null)
{
    cls
    $SpoolerGPOs | out-host
    echo "" | out-host
    echo "Please verify these are only related to PrintNightmare" | out-host
    echo "" | out-host
    $DeleteSpoolerGPOs = read-host "Continue? (Y/N)"
    
    #If the user does not choose to continue, they will be adviced to manually clean up the policies, and exit the script.
    if ($DeleteSpoolerGPOs -ne "y")
    {
        cls
        write-host "Please manually clean up policies."
        pause
        cls
        break
    }
    #If the user chooses to proceed, all previously listed GPOs will be deleted.
    foreach ($SpoolerGPO in $SpoolerGPOs)
    {
        $Spooler = $SpoolerGPO.Displayname
        Remove-GPO -Name $Spooler
    }
}
else
{
    cls
    write-host "No GPOs relating to a PrintNightmare workaround has been found" -ForegroundColor Red
    sleep 1
}
#Detects if a previous download of dependecies exist, if it does, it will delete it, as a new and ensured complete package is downloaded.
$DoesDependsExist = Test-Path -Path C:\PrintNightmareTemp
if ($DoesDependsExist -eq $true)
{
    Remove-Item –path C:\PrintNightmareTemp –recurse -Force
}

#Downloads dependencies
New-Item -ItemType "directory" -Path C:\PrintNightmareTemp
sleep 1
$GPOURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL3Bja3RzL1ByaW50TmlnaHRtYXJlV29ya2Fyb3VuZC9yYXcvbWFpbi9HUE9zLnppcA=="))
Invoke-WebRequest -Uri $GPOURL -OutFile C:\PrintNightmareTemp\GPOs.zip
sleep 1

#Attempts to unzip the downloaded archive of dependencies, if this fails it will be because WMF 5.1 is not installed.
#The script will inform the user about this and give an option to open the download page for them.
#Regardless of which option is chosen, the script will exit, as it is impossible to continue without these dependencies.
#(It is possible to proceed without this dependency by manually unzipping and manually running this script in parts, but it is highly inadvisable)
Try
{
    Expand-Archive -LiteralPath 'C:\PrintNightmareTemp\GPOs.zip' -DestinationPath C:\PrintNightmareTemp
}
catch
{
    cls
    write-host "Powershell version is outdated and does not contain required functionality."
    write-host "Please download and install Windows Management Framework 5.1"
    write-host "You can not continue until this is installed."
    write-host ""
    $DownloadWMF = read-host "Do you want to go to the download page before closing? (Y/N)"
    if ($DownloadWMF = "y")
    {
        Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=54616"
        cls
        break
    }
    else
    {
        break
    }
}
#Presents a series of choices to the user. The sum of these choices will determine which GPO will be deployed.
#None of the choices can be bypassed and require a valid input, and will not proceed otherwise.

#The first choice being if they want to enable or disable the printspooler.
$SpoolerChoice = 
{
    cls
    write-host "Do you want to enable or disable the printspooler?"
    $DesiredSpoolerState = read-host "(E)nable/(D)isable"
    if ($DesiredSpoolerState -ne "d" -and $DesiredSpoolerState -ne "e")
    {
        &@SpoolerChoice
    }
    else
    {
        #The second choice being if they want to enable or disable remote printing functionality
        $RemoteChoice = 
        {
            cls
            write-host "Do you want to enable or disable remote printing?"
            $DesiredRemoteState = read-host "(E)nable/(D)isable"
            if ($DesiredRemoteState -ne "d" -and $DesiredRemoteState -ne "e")
            {
                &@RemoteChoice
            }
            else
            {
                #The third and final choice being if they want to enable or disable "Point and Print" functionality
                $PAPChoice = 
                {
                    cls
                    write-host "Do you want to enable or disable Point and Print?"
                    $DesiredPAPState = read-host "(E)nable/(D)isable"
                    if ($DesiredPAPState -ne "d" -and $DesiredPAPState -ne "e")
                    {
                        &@PAPChoice
                    }
                    else
                    {
                        #Creates variables for the GPO GUIDs for convenience
                        $111 = "23E036C2-B247-4717-9A43-41F3212F8DC0"
                        $110 = "D73E9B1F-1906-4382-A650-B4C1DC7B5E7E"
                        $101 = "2885612A-32D1-4CAA-B730-F5C9C6F1B2E7"
                        $100 = "77F9D898-8EB1-437D-B1C2-91E04E14996D"
                        $011 = "9EB906D5-2E15-4091-A790-450E03449E1B"
                        $010 = "CA478F98-53BD-4C7C-920E-4C76F2E0485C"
                        $001 = "96599A76-E0AA-45D7-B1C2-577F974E7D6A"
                        $000 = "6BCBC833-D657-4F04-AEE7-EEA92CA99395"

                        #Scriptblock that will be used to select what versions of devices to target.
                        #This code is not run at first appearance but is called in later.
                        $ServerVersionChoice =
                        {
                                                        
                            #Gets all devices of a certain OS version and creates an array of these.

                            #Server versions
                            $SRV2019 = (Get-ADcomputer -filter {operatingsystem -like "*2019*"} -Properties Name, OperatingSystem).name
                            $SRV2016 = (Get-ADcomputer -filter {operatingsystem -like "*2016*"} -Properties Name, OperatingSystem).name
                            $SRV2012 = (Get-ADcomputer -filter {operatingsystem -like "*2012*"} -Properties Name, OperatingSystem).name
                            $SRVOLD  = (Get-ADcomputer -filter {operatingsystem -like "*200*"}  -Properties Name, OperatingSystem).name

                            #Client versions
                            $WIN10  = (Get-ADcomputer -filter {operatingsystem -like "Windows 10*"} -Properties Name, OperatingSystem).name
                            $WINOLD = (Get-ADcomputer -filter {operatingsystem -notlike "Windows 10*" -and operatingsystem -notlike "*Server*"} -Properties Name, OperatingSystem).name

                            #Presents the possible options to the user and lets them choose the combination of device versions they desire
                            #This will loop until it is exited on purpose. It is not possible to pick the same option twice. (nothing will happen after first time)
                            $AddedDeviceGroups = {$hostname}.Invoke()
                            while ($AddedDeviceGroup -ne "done")
                            {
                                sleep 1
                                cls
                                write-host "Possible groups of target devices:" -ForegroundColor Green
                                write-host ""
                                write-host "(1). Server 2019"
                                write-host "(2). Server 2016"
                                write-host "(3). Server 2012 and 2012R2"
                                write-host "(4). Server 2008R2 and earlier"
                                write-host ""
                                write-host "(5). Windows 10"
                                write-host "(6). Windows 8.1 and earlier"
                                write-host ""
                                write-host ""
                                write-host "Targetted devices:" -ForegroundColor Red
                                $AddedDeviceGroups
                                write-host;
                                write-host ""
                                write-host "--------------------------------------------------------" -ForegroundColor DarkGray
                                write-host ""
                                write-host "Please input what devices you want to apply the changes to, one at a time."
                                write-host "Please be absolutely sure of the devices you add, as the only easy way to add or remove devices later is to start over."
                                write-host "If you accidentally add an unintended group, you can 'add' it again to remove it"
                                write-host ""
                                write-host "Type 'done' when you do not want to add any more device groups"
                                $AddedDeviceGroup = Read-Host "Option"
                                #Append array to array of arrays. Append list of servers (an array) to the desireddevices array
                                ###################################################################################################################################################################################################################################################################################

                                #Detects if a valid input is selected and lists the option as "picked" on the screen. The handling of duplicate choices is also here.
                                #In a later instance, the devices belonging to the chosen group, will be added to an array that is used later for actual deployment.
                                #If you pick an existing option, it will be removed
                                #A "block" exists for each group of devices, they function identically.
                                if ($AddedDeviceGroup -eq "1")
                                {
                                    if ($AddedDeviceGroups.Contains("Server 2019") -ne $true)
                                    {
                                        $AddedDeviceGroups.Add("Server 2019")
                                    }
                                    else
                                    {
                                        $AddedDeviceGroups.Remove("Server 2019")
                                    }
                                }
                                if ($AddedDeviceGroup -eq "2")
                                {
                                    if ($AddedDeviceGroups.Contains("Server 2016") -ne $true)
                                    {
                                        $AddedDeviceGroups.Add("Server 2016")
                                    }
                                    else
                                    {
                                        $AddedDeviceGroups.Remove("Server 2016")
                                    }
                                }
                                if ($AddedDeviceGroup -eq "3")
                                {
                                    if ($AddedDeviceGroups.Contains("Server 2012 and 2012R2") -ne $true)
                                    {
                                        $AddedDeviceGroups.Add("Server 2012 and 2012R2")
                                    }
                                    else
                                    {
                                        $AddedDeviceGroups.Remove("Server 2012 and 2012R2")
                                    }
                                }
                                if ($AddedDeviceGroup -eq "4")
                                {
                                    if ($AddedDeviceGroups.Contains("Server 2008R2 and earlier") -ne $true)
                                    {
                                        $AddedDeviceGroups.Add("Server 2008R2 and earlier")
                                    }
                                    else
                                    {
                                        $AddedDeviceGroups.Remove("Server 2008R2 and earlier")
                                    }
                                }
                                if ($AddedDeviceGroup -eq "5")
                                {
                                    if ($AddedDeviceGroups.Contains("Windows 10") -ne $true)
                                    {
                                        $AddedDeviceGroups.Add("Windows 10")
                                    }
                                    else
                                    {
                                        $AddedDeviceGroups.Remove("Windows 10")
                                    }
                                }
                                if ($AddedDeviceGroup -eq "6")
                                {

                                    if ($AddedDeviceGroups.Contains("Windows 8.1 and earlier") -ne $true)
                                    {
                                        $AddedDeviceGroups.Add("Windows 8.1 and earlier")
                                    }
                                    else
                                    {
                                        $AddedDeviceGroups.Remove("Windows 8.1 and earlier")
                                    }
                                }
                            }
                            $AddedDeviceGroups.RemoveAt(0)
                            $AddedDeviceGroups.Remove("done")

                            #Adds the devices from respective groups to the array used for actual deployment
                            if ($AddedDeviceGroups.Contains("Server 2019") -eq $true)
                            {
                                $DesiredDevices += $SRV2019
                            }
                            if ($AddedDeviceGroups.Contains("Server 2016") -eq $true)
                            {
                                $DesiredDevices += $SRV2016
                            }
                            if ($AddedDeviceGroups.Contains("Server 2012 and 2012R2") -eq $true)
                            {
                                $DesiredDevices += $SRV2012
                            }
                            if ($AddedDeviceGroups.Contains("Server 2008R2 and earlier") -eq $true)
                            {
                                $DesiredDevices += $SRVOLD
                            }
                            if ($AddedDeviceGroups.Contains("Windows 10") -eq $true)
                            {
                                $DesiredDevices += $WIN10
                            }
                            if ($AddedDeviceGroups.Contains("Windows 8.1 and earlier") -eq $true)
                            {
                                $DesiredDevices += $WINOLD
                            }
                            if ($AddedDeviceGroups.Contains("Server 2019") -ne $true -and $AddedDeviceGroups.Contains("Server 2016") -ne $true -and $AddedDeviceGroups.Contains("Server 2012 and 2012R2") -ne $true -and $AddedDeviceGroups.Contains("Server 2008R2 and earlier") -ne $true -and $AddedDeviceGroups.Contains("Windows 10") -ne $true -and $AddedDeviceGroups.Contains("Windows 8.1 and earlier") -ne $true)
                            {
                                write-warning "ERROR! - You have not picked any groups"
                                write-warning "Undoing changes and returning to main menu..."
                                sleep 2
                                $PreviousGPOs = Get-GPO -All | Where-Object {$_.displayname -like "PRTNMITR_*"}
                                foreach ($PreviousGPO in $PreviousGPOs)
                                {
                                    $PGPO = $PreviousGPO.Displayname
                                    Remove-GPO -Name $PGPO
                                }
                                Remove-Item –path C:\PrintNightmareTemp –recurse -Force
                                cls
                                &@banner
                            }

                            cls
                            Write-host "The chosen policies will now be applied to the chosen device groups..."
                            sleep 2                                  
                                
                            #Applies the previously chosen GPO to the chosen groups of devices and finally exits.. by returning to the main menu
                            ForEach ($DesiredDevice in $DesiredDevices) 
                            {
                                Set-GPPermission -name $DesiredGPO -Targetname "$DesiredDevice" -TargetType Computer -PermissionLevel GpoApply
                            }
                            cls
                            write-host ""
                            write-host "DONE." -ForegroundColor Red
                            sleep 3
                            break
                        }
                        #The next 8 blocks of code are almost identical
                        #The blocks select a GPO based on previous choices and deploys and links it in the domain.
                        #Afterwards the user will be directed to the previous block that lets them choose what devices to target    
                        if ($DesiredSpoolerState -eq "e" -and $DesiredRemoteState -eq "e" -and $DesiredPAPState -eq "e")
                        {
                            $GPOName = "PRTNMITR_SpoolerEnable-RemoteEnable-PAPEnable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $111 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice     
                        }
                        if ($DesiredSpoolerState -eq "e" -and $DesiredRemoteState -eq "e" -and $DesiredPAPState -eq "d")
                        {
                            $GPOName = "PRTNMITR_SpoolerEnable-RemoteEnable-PAPDisable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $110 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice    
                        }
                        if ($DesiredSpoolerState -eq "e" -and $DesiredRemoteState -eq "d" -and $DesiredPAPState -eq "e")
                        {
                            $GPOName = "PRTNMITR_SpoolerEnable-RemoteDisable-PAPEnable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $101 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice 
                        }
                        if ($DesiredSpoolerState -eq "e" -and $DesiredRemoteState -eq "d" -and $DesiredPAPState -eq "d")
                        {
                            $GPOName = "PRTNMITR_SpoolerEnable-RemoteDisable-PAPDisable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $100 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice 
                        }
                        if ($DesiredSpoolerState -eq "d" -and $DesiredRemoteState -eq "e" -and $DesiredPAPState -eq "e")
                        {
                            $GPOName = "PRTNMITR_SpoolerDisable-RemoteEnable-PAPEnable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $011 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice 
                        }
                        if ($DesiredSpoolerState -eq "d" -and $DesiredRemoteState -eq "e" -and $DesiredPAPState -eq "d")
                        {
                            $GPOName = "PRTNMITR_SpoolerDisable-RemoteEnable-PAPEnable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $010 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice 
                        }
                        if ($DesiredSpoolerState -eq "d" -and $DesiredRemoteState -eq "d" -and $DesiredPAPState -eq "e")
                        {
                            $GPOName = "PRTNMITR_SpoolerDisable-RemoteEnable-PAPEnable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $001 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice 
                        }
                        if ($DesiredSpoolerState -eq "d" -and $DesiredRemoteState -eq "d" -and $DesiredPAPState -eq "d")
                        {
                            $GPOName = "PRTNMITR_SpoolerDisable-RemoteEnable-PAPEnable"
                            $Partition = Get-ADDomainController | Select DefaultPartition
                            $GPOSource = "C:\PrintNightmareTemp\"
                            import-gpo -BackupId $000 -TargetName $GPOName -path $GPOSource -CreateIfNeeded
                            Get-GPO -Name $GPOName | New-GPLink -Target $Partition.DefaultPartition
                            Set-GPLink -Name $GPOName -Enforced Yes -Target $Partition.DefaultPartition
                            $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
                            foreach ($B in $Blocked) 
                            {
                                New-GPLink -Name $GPOName -Target $B.Path
                                Set-GPLink -Name $GPOName -Enforced Yes -Target $B.Path
                            }
                            $DesiredGPO = $GPOName
                            &@ServerVersionChoice 
                        }
                    }
                }
                &@PAPChoice
            }
        }
        &@RemoteChoice 
    }
}
&@SpoolerChoice
