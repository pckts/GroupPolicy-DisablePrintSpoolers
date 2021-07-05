#Run entire script(as admin), you will make choices during the execution, so don't make partial runs unless you know what you're doing.

import-module activedirectory
cls
# Create "PrintSpoolerEnable" & "PrintSpoolerDisable" in default partition

New-Item -ItemType "directory" -Path C:\PrintNightmareTemp
sleep 1
$GPOURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL3Bja3RzL1ByaW50TmlnaHRtYXJlV29ya2Fyb3VuZC9yYXcvbWFpbi9HUE9zLnppcA=="))
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $GPOURL -OutFile C:\PrintNightmareTemp\GPOs.zip
sleep 1
Expand-Archive -LiteralPath 'C:\PrintNightmareTemp\GPOs.zip' -DestinationPath C:\PrintNightmareTemp

$Partition = Get-ADDomainController | Select DefaultPartition
$GPOSource = "C:\PrintNightmareTemp\"
import-gpo -BackupId 5B46EE9F-4746-4A41-910C-C4335DA0B84C -TargetName PrintSpoolerEnable -path $GPOSource -CreateIfNeeded
import-gpo -BackupId 508977A2-4737-430C-83B8-6DA9497ADA03 -TargetName PrintSpoolerDisable -path $GPOSource -CreateIfNeeded
Get-GPO -Name "PrintSpoolerDisable" | New-GPLink -Target $Partition.DefaultPartition
Get-GPO -Name "PrintSpoolerEnable" | New-GPLink -Target $Partition.DefaultPartition
Set-GPLink -Name "PrintSpoolerEnable" -Enforced Yes -Target $Partition.DefaultPartition
Set-GPPermission -name "PrintSpoolerEnable" -Targetname "Authenticated Users" -TargetType Group -PermissionLevel None -Replace

Remove-Item –path C:\PrintNightmareTemp –recurse -Force

#----------------

# EnableSpooler on W7 & W10 computers 
$ExcludeClients = Read-Host "Do you want to keep printspooler enabled on clients? (Y/N)"
if ($ExcludeClients -eq "y")
{
$W10 = Get-ADcomputer -filter {operatingsystem -like "Windows 10*"} -Properties Name, OperatingSystem | Select Name
$W7 = Get-ADcomputer -filter {operatingsystem -like "Windows 7*"} -Properties Name, OperatingSystem | Select Name

ForEach ($W in $W10) {
$Name1 = $W.Name
Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$Name1" -TargetType Computer -PermissionLevel GpoApply
Write-Host "GPO applied to $Name1" -ForegroundColor Green
}

ForEach ($V in $W7) {
$Name2 = $V.Name
Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$Name2" -TargetType Computer -PermissionLevel GpoApply
Write-Host "GPO applied to $Name2" -ForegroundColor Green
}
}
pause
$createlist = {
cls
write-host "Please create CSV file for servers to exclude before proceeding."
write-host "See comment within script code."
<# 
CSV file content:

Name,
Servername1
Servername2
Servername3

#>
pause
$Listexists = Test-Path -Path C:/Exclude.csv -PathType Leaf
if ($Listexists -eq "true")
{
$ComputerObject = Import-csv C:/Exclude.csv
$Computer = $ComputerObject.Name
 
ForEach ($Name in $Computer) {
Set-GPPermission -name "PrintSpoolerEnable" -Targetname "$Name" -TargetType Computer -PermissionLevel GpoApply
Write-Host "GPO applied to $Name" -ForegroundColor Green
}
write-host "Done"
sleep 2
exit
}
else
{
write-host "File does not exist.."
sleep 2
&@createlist
}
}
&@createlist
