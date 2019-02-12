#Set Logfile
 
$logfile = "$env:systemdrive\Temp\DW-remove.log"
#Set Service List
 
$ServiceList = "DWMRCS",
"DNTUS26"
#Set Registry Path
 
$RegPathList = "HKLM:\Software\DameWare Development"
#MSI Code List
$MSICodeList =
"{385FED21-85D3-401E-8B8A-38140333FAC8}", #x64 installer
"{9F660272-3D31-47CE-BEB6-7A065B8901A5}" #x32 installer
#List of Files to search for
$FindFileList =
"DWRCS.EXE", #Dameware remote control service
"DNTUS26.EXE" #Dameware utility service
#Parent folder to delete if it exists.
$FindFolder =
"DWRCS" #Known location of Dameware files; also known to reside in the system32 folder but we don't want to delete system32 #Define Functions
Function
GetTimeDate {
 
$Month = Get-Date -Format MM
$Day = Get-Date -Format dd
$Year = Get-Date -Format yyyy
$Hour = Get-Date -Format hh
$Minute = Get-Date -Format mm
$Seconds = Get-Date -Format ss
$SecondsF = Get-Date -Format fff
 
$TimeDate = ($Month + "-" + $Day + "-" + $Year + "_" + $Hour + ":" + $Minute + ":" + $Seconds + "." + $SecondsF)Return $TimeDate }
Function
OutLog {
((
GetTimeDate) + " " + $LogBuffer) | out-file -FilePath $logfile -Append
{
 
switch -Wildcard ($LogBuffer)"Error*" {
 
write-host ((GetTimeDate) + " " + $LogBuffer) -ForegroundColor Red }
 
"Warning*" {
 
write-host ((GetTimeDate) + " " + $LogBuffer) -ForegroundColor Yellow }
 
Default {
 
}
}
}
write-host ((GetTimeDate) + " " + $LogBuffer) Function
{
 
{
 
{
 
filedelete($folder)foreach ($filename in $CompanionFileList) if (Test-Path ($folder.DirectoryName + "\" + $filename))$LogBuffer = ($folder.DirectoryName + "\" + $filename) + " was found."
outlog
$LogBuffer = "Deleting " + ($folder.DirectoryName + "\" + $filename) + "."
outlog
Remove-Item ($folder.DirectoryName + "\" + $filename) -ErrorAction SilentlyContinue
{
 
if (Test-Path ($folder.DirectoryName + "\" + $filename))$LogBuffer = "Error: " + $folder.DirectoryName + "\" + $filename + " was not deleted."
outlog }
 
{
 
else $LogBuffer = ($folder.DirectoryName + "\" + $filename) + " was successfully deleted."
outlog }
}
 
else {
 
$LogBuffer = "Warning: " + ($folder.DirectoryName + "\" + $filename) + " was not found."
outlog }
}
}
Function
{
 
{
 
{
 
FolderDelete($folder)if ($folder.DirectoryName -like "*" + $FindFolder)if (remove-item $folder.DirectoryName -recurse -force -ErrorAction SilentlyContinue)$LogBuffer = ($folder.DirectoryName) + " was successfully deleted."
outlog }
 
{
 
else $LogBuffer = "Error: " + ($folder.DirectoryName) + " was not successfully deleted."
outlog }
}
}
Function
FindFile {
 
{
 
foreach ($FindFile in $FindFileList)$LogBuffer = "Searching for " + $FindFile + "."
outlog
$files = Get-ChildItem -path $env:systemroot -Filter $FindFile -Recurse -ErrorAction SilentlyContinue
{
 
if ($files -eq $null)$LogBuffer = "Warning: "+ $FindFile + " was not found."
outlog }
 
else {
 
$LogBuffer = "Found " + $FindFile + " in " + $Files.DirectoryNameoutlog
{
 
}
}
}
}
foreach ($folder in $files) filedelete($folder)folderdelete($folder) Function
MSIx {
 
{
 
foreach ($MSICode in $MSICodeList)$LogBuffer = "Executing MSI Uninstall string: MSIEXEC.EXE /X" + $MSICode + " /QN /NORESTART"
outlog
 
{
 
{
 
$Exit = (start-process -FilePath "MSIEXEC.EXE" -argumentlist "/X$MSICode /QN /NORESTART" -wait -passthru).ExitCodeSwitch($Exit)"1603" $LogBuffer = "MSI Result Code was: " + $Exit + " Error: Fatal error during uninstallation. Application not removed."
outlog }
 
"1605" {
 
$LogBuffer = "Warning: MSI Result Code was: " + $Exit + " Application is not installed."
outlog }
 
"0" {
 
$LogBuffer = "Warning: MSI Result code was: " + $Exit + " Application successfully uninstalled."
outlog
MSISuccessHandler }
 
Default {
 
$LogBuffer = "Error: MSI Result Code was: " + $Exit
outlog }
}
}
}
$LogBuffer
= "It looks like PowerShell." outlog
Function
DeleteService {
 
{
 
{
 
foreach ($ServiceName in $Servicelist)if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)$ServName = Get-Service -Name $ServiceName
$LogBuffer = "The service '" + $ServName.DisplayName + "' was found."
outlog
$LogBuffer = "Stopping service: '" + $ServName.DisplayName + "'"
outlog
Set-Service $ServName.Name -Status Stopped
 
$ServiceStatus = Get-Service -Name $ServName.Name$LogBuffer = "The Service: '" + $ServName.DisplayName + "' is " + $ServiceStatus.Status + "."
outlog
$LogBuffer = "Deleting the service '" + $ServName.DisplayName + "'."
outlog
 
$null = (Get-WmiObject win32_service | where {$_.Name -Like $ServName.Name}).delete()sleep -Seconds 49244925
 
{
 
if (Get-Service -Name $ServName.Name -ErrorAction SilentlyContinue)$LogBuffer = "Error: The service: '" + $ServName.DisplayName + "' was not deleted."
}
 
outlog else {
 
$LogBuffer = "The service: '" + $ServName.DisplayName + "' was successfully deleted."
outlog }
}
 
else {
 
$LogBuffer = "Warning: The service: '" + $ServiceName + "' was not found."
outlog }
}
}
Function
RegClean {
 
{
 
{
 
foreach ($RegPath in $RegPathList)if (Test-Path $RegPath)$LogBuffer = $RegPath + " was found in the registry."
outlog
$LogBuffer = "Deleting " + $RegPath + "."
outlog
Remove-Item $RegPath -Recurse -Force
{
 
if (Test-Path $RegPath)$LogBuffer = "Error: " + $RegPath + " was not deleted from the registry."
outlog }
 
else {
 
$LogBuffer = $RegPath + " was successfully deleted from the registry."
outlog }
}
 
else {
 
$LogBuffer = "Warning: " + $RegPath + " was not found in the registry."
outlog }
}
}
Function
StartLog {
 
$LogBuffer = "----====Logging started====----"
outlog }
Function
StopLog {
 
$LogBuffer = "----====Logging stopped====----"
outlog }
Function
MSISuccessHandler {
 
{
 
if ($Exit -eq "0")$LogBuffer = "Warning: MSI uninstall was successful. Remainder of script is probably not necessary."
outlog }
}
#Do all the things
StartLog
MSIx
DeleteService
FindFile
RegClean
StopLog
