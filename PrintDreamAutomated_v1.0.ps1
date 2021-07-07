#Created by packet and MTossen

#Cleans up after PrintNightmareAutomated when system is patched.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = "SilentlyContinue"
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted | out-null
import-module activedirectory | out-null
install-module Microsoft.powershell.archive | out-null
import-module Microsoft.powershell.archive | out-null
$SpoolerGPOs = Get-GPO -All | Where-Object {$_.displayname -like "*spooler*" -or $_.displayname -like "*nightmare*"} | Select displayname
cls
$SpoolerGPOs | out-host
echo "" | out-host
echo "Please verify these are only related to PrintNightmare and not existing spoolers." | out-host
echo "" | out-host
$DeleteSpoolerGPOs = read-host "Continue? (Y/N)"
if ($DeleteSpoolerGPOs -ne "y")
{
    cls
    write-host "Please manually clean up policies."
    pause
    cls
    break
}
foreach ($SpoolerGPO in $SpoolerGPOs)
{
$Spooler = $SpoolerGPO.Displayname
    Remove-GPO -Name $Spooler
}
cls
$DoesDependsExist = Test-Path -Path C:\PrintNightmareTemp
if ($DoesDependsExist -eq $true)
{
    Remove-Item –path C:\PrintNightmareTemp –recurse -Force
}
New-Item -ItemType "directory" -Path C:\PrintNightmareTemp
sleep 1
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
$Partition = Get-ADDomainController | Select DefaultPartition
$GPOSource = "C:\PrintNightmareTemp\"
import-gpo -BackupId 5B46EE9F-4746-4A41-910C-C4335DA0B84C -TargetName PrintSpoolerEnable -path $GPOSource -CreateIfNeeded
Get-GPO -Name "PrintSpoolerEnable" | New-GPLink -Target $Partition.DefaultPartition
Set-GPLink -Name "PrintSpoolerEnable" -Enforced Yes -Target $Partition.DefaultPartition
$Blocked = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
Foreach ($B in $Blocked) 
{
    New-GPLink -Name "PrintSpoolerEnable" -Target $B.Path
    Set-GPLink -Name "PrintSpoolerEnable" -Enforced Yes -Target $B.Path
}
cls
write-host ""
write-host "DONE" -ForegroundColor Green
write-host "Please manually verify that the policies are correct" -ForegroundColor Red
pause