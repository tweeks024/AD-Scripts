#
# Script Name: AD-MoveComputers.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   7.8.2015


##### MAIN #####

# Get all computers in Computers CN.  Uses OperatingSystem property to determine location.  Adds any server OS to "Server Policy Universal" AD Group unless name contains Group1 or Group2 in which case they go to "Server Policy Universal Group1"
# Uses Microsoft Technet Function for Write-Log from https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0

. c:\scripts\Function-Write-Log.ps1

$Computers = Get-ADComputer -Filter * -SearchBase "CN=Computers,DC=ad,DC=corp,DC=com" -Properties OperatingSystem

ForEach ($item in $Computers) {

$FriendlyName = $item.name
$ComputerName = $item.distinguishedName
$OS = $item.OperatingSystem

if ($OS -like "Windows Server*") {
	if (($FriendlyName -like "*Group1*") -or ($FriendlyName -like "*Group2*")) {
		ADD-ADGroupMember "Server Policy Universal Group1" -Members $ComputerName
		Move-ADObject $ComputerName -TargetPath "OU=Group1 Servers,OU=Servers,DC=ad,DC=corp,DC=com"
		Start-Sleep 60
		$NewDN = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty distinguishedName
		$NewGroup = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty MemberOf
		if (($NewDN -like "*OU=Group1 Servers,OU=Servers,DC=ad,DC=corp,DC=com") -and ($NewGroup -like "*Server Policy Universal Group1*")) {
			Write-Log -Message "$FriendlyName,$OS,Successful" -Path C:\Scripts\ADComputerMove\output.log }
		else {
			Write-Log -Message "$FriendlyName,$OS,Failed" -Path C:\Scripts\ADComputerMove\output.log -Level Error }
		}
	
	else {
		ADD-ADGroupMember "Server Policy Universal" -Members $ComputerName
		Move-ADObject $ComputerName -TargetPath "OU=Servers,DC=ad,DC=corp,DC=com"
		Start-Sleep 60
		$NewDN = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty distinguishedName
		$NewGroup = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty MemberOf
		if (($NewDN -like "*OU=Servers,DC=ad,DC=corp,DC=com") -and ($NewGroup -like "*Server Policy Universal*")) {
			Write-Log -Message "$FriendlyName,$OS,Successful" -Path C:\Scripts\ADComputerMove\output.log }
		else {
			Write-Log -Message "$FriendlyName,$OS,Failed" -Path C:\Scripts\ADComputerMove\output.log }
		}	
	}	
	
if ($OS -like "*Linux*") {
	Move-ADObject $ComputerName -TargetPath "OU=Servers,DC=ad,DC=corp,DC=com"
	Start-Sleep 60
	$NewDN = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty distinguishedName
	if ($NewDN -like "*OU=Servers,DC=ad,DC=corp,DC=com") {
		Write-Log -Message "$FriendlyName,$OS,Successful" -Path C:\Scripts\ADComputerMove\output.log }
	else {
		Write-Log -Message "$FriendlyName,$OS,Failed" -Path C:\Scripts\ADComputerMove\output.log }
	}		
	
if ($OS -like "Windows 7*") {
	Move-ADObject $ComputerName -TargetPath "OU=Workstations,DC=ad,DC=corp,DC=com"
	Start-Sleep 60
	$NewDN = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty distinguishedName
	if ($NewDN -like "*OU=Workstations,DC=ad,DC=corp,DC=com") {
		Write-Log -Message "$FriendlyName,$OS,Successful" -Path C:\Scripts\ADComputerMove\output.log }
	else {
		Write-Log -Message "$FriendlyName,$OS,Failed" -Path C:\Scripts\ADComputerMove\output.log }
	}		
	
if ($OS -like "*Mac*") {
	Move-ADObject $ComputerName -TargetPath "OU=Mac,OU=Workstations,DC=ad,DC=corp,DC=com"
	Start-Sleep 60
	$NewDN = Get-ADComputer $FriendlyName -Properties * | Select-Object -ExpandProperty distinguishedName
	if ($NewDN -like "*OU=Mac,OU=Workstations,DC=ad,DC=corp,DC=com") {
		Write-Log -Message "$FriendlyName,$OS,Successful" -Path C:\Scripts\ADComputerMove\output.log }
	else {
		Write-Log -Message "$FriendlyName,$OS,Failed" -Path C:\Scripts\ADComputerMove\output.log }
	}

else {
	#Nothing to see here
	}
}


##### Alerting #####

#Get log output.  If any failures, send failure report otherwise send success report.

$LogOuput = Get-Content C:\scripts\ADComputerMove\output.log
$Body = Write-Output $LogOuput | Out-String
	if ($LogOuput -like "*Failed*") {
		Send-MailMessage -to tom.weeks@corp.com -from "NTAlerts <ntalerts@corp.com>" -subject "AD Object Move FAILED" -body $Body -priority High -smtpServer mail.corp.com }
	else {
		Send-MailMessage -to tom.weeks@corp.com -from "NTAlerts <ntalerts@corp.com>" -subject "AD Object Move Successful" -body $Body -smtpServer mail.corp.com }


##### Log Maintenance #####

#Rename log to yyyy-MM-dd.log and then remove .log files older than 180 logs.  Log removed files to LogCleanup.txt.
		
Get-ChildItem C:\Scripts\ADComputerMove\out* | Rename-Item -NewName "$(get-date -f yyyy-MM-dd).log"

$Now = Get-Date
$Days = "180"
$TargetFolder = "C:\Scripts\ADComputerMove"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

$Files = Get-ChildItem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        Write-Output "$Now Deleting File $File"  >> C:\Scripts\ADComputerMove\LogCleanup.txt
        Remove-Item $File.FullName | Out-Null
        }
    else
        {
        Write-Output "$No New Files to Delete!"  >> C:\Scripts\ADComputerMove\LogCleanup.txt
        }
    }
