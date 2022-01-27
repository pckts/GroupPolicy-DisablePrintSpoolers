# Created by packet and mtossen for https://www.parceu.com

# Disables all printspoolers across the entire domain enviornment
# Must be run on a DC

# Note: Non-functional due to GPO download source deletion.

#========#
# ^^^^^^ #
# README #
#========#

########################################################################################################################################################################################################################

#Run entire script(as admin), you will make choices during the execution, so don't make partial runs unless you know what you're doing.

#Sets TLS version to 1.2. This is needed for HTTPS connection to download neccesary files, as well as install the Archive module. (and more)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Imports the neccesary modules to access the cmdlets used in the script.
$ProgressPreference = "SilentlyContinue"
import-module activedirectory | out-null
#Tries to import before installing, as installing takes a long time.
try
{
    import-module Microsoft.powershell.archive | out-null
}
catch
{
    install-module Microsoft.powershell.archive | out-null
}
cls

#Creates the folder "PrintNightmareTemp" in the C:\ directory, to store temporary files as theyre downloaded and unzipped during the process.
$DoesDependsExist = Test-Path -Path C:\PrintNightmareTemp
if ($DoesDependsExist -eq $true)
{
    Remove-Item –path C:\PrintNightmareTemp –recurse -Force
}
New-Item -ItemType "directory" -Path C:\PrintNightmareTemp
sleep 1

#Downloads the GPOs.zip folder and puts it into the PrintnightmareTemp folder.
$GPOURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL3Bja3RzL1ByaW50TmlnaHRtYXJlV29ya2Fyb3VuZC9yYXcvbWFpbi9HUE9zLnppcA=="))
Invoke-WebRequest -Uri $GPOURL -OutFile C:\PrintNightmareTemp\GPOs.zip
sleep 1

#Unzips the GPOs.zip folder so the 2 GPO's are available as regular folders. This is neccesary to import them later.
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
#Imports the GPOs and links them at domain root
$Partition = Get-ADDomainController | Select DefaultPartition
$GPOSource = "C:\PrintNightmareTemp\"
import-gpo -BackupId 5B46EE9F-4746-4A41-910C-C4335DA0B84C -TargetName PrintSpoolerEnable -path $GPOSource -CreateIfNeeded
import-gpo -BackupId 508977A2-4737-430C-83B8-6DA9497ADA03 -TargetName PrintSpoolerDisable -path $GPOSource -CreateIfNeeded
Get-GPO -Name "PrintSpoolerDisable" | New-GPLink -Target $Partition.DefaultPartition
Get-GPO -Name "PrintSpoolerEnable" | New-GPLink -Target $Partition.DefaultPartition
cls
write-host "(Alternative: Any other input to just get a list of servers)"
write-host ""
write-host "Solution 1: Disable for all servers and clients"
write-host "Solution 2: Disable for some servers and clients"
$FixMethod = read-host "Solution 1 or 2? (1/2)"
if ($FixMethod -eq 1)
{
    #If solution 1 is picked: The PrintSpoolerDisable GPO is enforced.
    Set-GPLink -Name "PrintSpoolerDisable" -Enforced Yes -Target $Partition.DefaultPartition
    #Checks if inheritance is blocked for any OUs, in which case it will link the GPO to those OUs.
    $Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
    Foreach ($B in $Blocked) 
    {
        New-GPLink -Name "PrintSpoolerDisable" -Target $B.Path
        Set-GPLink -Name "PrintSpoolerDisable" -Enforced Yes -Target $B.Path
    }
    #Deletes the PrintSpoolerEnable GPO as it's not needed for solution 1
    Remove-GPO -Name "PrintSpoolerEnable"
    write-host "Done."
    sleep 5
    #Cleans up and exits
    Remove-Item –path C:\PrintNightmareTemp –recurse -Force
    break
}
if ($FixMethod -ne 1 -and $FixMethod -ne 2)
{
    Get-ADComputer -Filter * -Properties Name, OperatingSystem | Where {$_.OperatingSystem -like "*SERVER*"} | Select Name | Clip
    cls
    write-host "A server list is now in your clipboard. Please paste into a text field."
    pause
    Remove-Item –path C:\PrintNightmareTemp –recurse -Force
    break
}
$Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
Foreach ($B in $Blocked) 
{
    New-GPLink -Name "PrintSpoolerDisable" -Target $B.Path
    New-GPLink -Name "PrintSpoolerEnable" -Target $B.Path
    Set-GPLink -Name "PrintSpoolerEnable" -Enforced Yes -Target $B.Path
}
Set-GPLink -Name "PrintSpoolerEnable" -Enforced Yes -Target $Partition.DefaultPartition
Set-GPPermission -name "PrintSpoolerEnable" -Targetname "Authenticated Users" -TargetType Group -PermissionLevel None -Replace

cls
$ExcludeClients = Read-Host "Do you want to keep printspooler enabled on clients? (Y/N)"
if ($ExcludeClients -eq "y")
{
    $W10 = Get-ADcomputer -filter {operatingsystem -like "Windows 10*"} -Properties Name, OperatingSystem | Select Name
    $W7 = Get-ADcomputer -filter {operatingsystem -like "Windows 7*"} -Properties Name, OperatingSystem | Select Name
    ForEach ($W in $W10) 
    {
        Try 
        {
            $Name1 = $W.Name
            Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$Name1" -TargetType Computer -PermissionLevel GpoApply
            Write-Host "GPO applied to $Name1" -ForegroundColor Green
        }
        catch
        {
            $SecondGPOState = Get-GPO -Name "PrintSpoolerEnable2"
            if ($SecondGPOState -eq $null)
            {
                $Partition = Get-ADDomainController | Select DefaultPartition
                $GPOSource = "C:\PrintNightmareTemp\"
                import-gpo -BackupId 5B46EE9F-4746-4A41-910C-C4335DA0B84C -TargetName PrintSpoolerEnable2 -path $GPOSource -CreateIfNeeded
                Get-GPO -Name "PrintSpoolerEnable2" | New-GPLink -Target $Partition.DefaultPartition
                Set-GPLink -Name "PrintSpoolerEnable2" -Enforced Yes -Target $Partition.DefaultPartition
                Set-GPPermission -name "PrintSpoolerEnable2" -Targetname "Authenticated Users" -TargetType Group -PermissionLevel None -Replace
            }
            $Name1 = $W.Name
            Set-GPPermission -name "PrintSpoolerEnable2" -Targetname "$Name1" -TargetType Computer -PermissionLevel GpoApply
            Write-Host "GPO applied to $Name1" -ForegroundColor Green
        }
    }
    ForEach ($V in $W7)
    {
        Try
        {
            $Name2 = $v.Name
            Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$Name2" -TargetType Computer -PermissionLevel GpoApply
            Write-Host "GPO applied to $Name2" -ForegroundColor Green
        }
        catch
        {
            $SecondGPOState = Get-GPO -Name "PrintSpoolerEnable2"
            if ($SecondGPOState -eq $null)
            {
                $Partition = Get-ADDomainController | Select DefaultPartition
                $GPOSource = "C:\PrintNightmareTemp\"
                import-gpo -BackupId 5B46EE9F-4746-4A41-910C-C4335DA0B84C -TargetName PrintSpoolerEnable2 -path $GPOSource -CreateIfNeeded
                Get-GPO -Name "PrintSpoolerEnable2" | New-GPLink -Target $Partition.DefaultPartition
                Set-GPLink -Name "PrintSpoolerEnable2" -Enforced Yes -Target $Partition.DefaultPartition
                Set-GPPermission -name "PrintSpoolerEnable2" -Targetname "Authenticated Users" -TargetType Group -PermissionLevel None -Replace
            }
            $Name2 = $v.Name
            Set-GPPermission -name "PrintSpoolerEnable2" -Targetname "$Name2" -TargetType Computer -PermissionLevel GpoApply
            Write-Host "GPO applied to $Name2" -ForegroundColor Green
        }
    }
}
$createlist = 
{
    cls
    write-host "Please add any servers that needs excluding"
    write-host "How do you want to add them? (Many = CSV, Few = Manual)"
    $CreateExclusionsHow = read-host "CSV File(C) or manual input(M)"
    if ($CreateExclusionsHow -eq "c")
    {
        $Listexists = Test-Path -Path C:/ITR/Exclude.csv -PathType Leaf
        if ($Listexists -eq "true")
        {
            $ComputerObject = Import-csv C:/ITR/Exclude.csv
            $Computer = $ComputerObject.Name
            ForEach ($Name in $Computer) 
            {
                Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$Name" -TargetType Computer -PermissionLevel GpoApply
                Write-Host "GPO applied to $Name" -ForegroundColor Green
            }
            cls
            write-host "Done"
            Remove-Item –path C:\PrintNightmareTemp –recurse -Force
            sleep 5
            break
        }
        else
        {
            write-host "File does not exist.."
            sleep 2
            &@createlist
        }
    }
    if ($CreateExclusionsHow -eq "m")
    {
        cls
        $ExcludedServs = {$hostname}.Invoke()
        while ($addedServ -ne "DONE")
        {
            if ($ExcludedServs -ne $null)
            {
                write-host "Servers to exclude:"
                $ExcludedServs
                write-host;
            }
            write-host "Please input server hostnames you want to exclude, one at a time. Type 'done' when finished."
            $addedServ = Read-Host "Hostname"
            $ExcludedServs.Add($addedServ)
            cls
        }
        $ExcludedServs.RemoveAt(0)
        $ExcludedServs.Remove("done")
        ForEach ($ExcludedServ in $ExcludedServs) 
        {
            Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$ExcludedServ" -TargetType Computer -PermissionLevel GpoApply
            Write-Host "GPO applied to $ExcludedServ" -ForegroundColor Green
        }
        cls
        write-host "Done"
        Remove-Item –path C:\PrintNightmareTemp –recurse -Force
        sleep 5
        break
    }
    else
    {
        cls
        write-host "Input not recognised, fallback to manual input"
        sleep 1
        $ExcludedServs = {$hostname}.Invoke()
        while ($addedServ -ne "DONE")
        {
            if ($ExcludedServs -ne $null)
            {
                write-host "Servers to exclude:"
                $ExcludedServs
                write-host;
            }
            write-host "Please input server hostnames you want to exclude, one at a time. Type 'done' when finished."
            $addedServ = Read-Host "Hostname"
            $ExcludedServs.Add($addedServ)
            cls
        }
        $ExcludedServs.RemoveAt(0)
        $ExcludedServs.Remove("done")
        ForEach ($ExcludedServ in $ExcludedServs) 
        {
            Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$ExcludedServ" -TargetType Computer -PermissionLevel GpoApply
            write-Host "GPO applied to $ExcludedServ" -ForegroundColor Green
        }
        cls
        write-host "Done"
        Remove-Item –path C:\PrintNightmareTemp –recurse -Force
        sleep 5
        break
    }
}
&@createlist
