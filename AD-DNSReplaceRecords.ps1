#
# Script Name: AD-DNSReplaceRecords.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   4.5.2013


##### MAIN #####

# Get new DNS records from csv file and replace old records with them.  Replicate changes throughout domain.  Used during Disaster Recovery events after Zerto failover.



$DNSServer = "DNSServer.corp.com"
$DNSZone = "corp.com"
$InputFile = "c:\!utils\dnsrecords.csv"

$records = Import-CSV $InputFile

ForEach ($record in $records) {


	$recordName = $record.name
	$recordType = $record.type
	$recordAddress = $record.address

	$cmdDelete = "dnscmd $DNSServer /RecordDelete $DNSZone $recordName $recordType /f"

	$cmdAdd = "dnscmd $DNSServer /RecordAdd $DNSZone $recordName $recordType $recordAddress"


	Write-Host "Running the following command: $cmdDelete"
	Invoke-Expression $cmdDelete

	Write-Host "Running the following command: $cmdAdd"
	Invoke-Expression $cmdAdd
}

$cmdReplicate = "repadmin /syncall /APed"

Write-Host "Running the command: $cmdReplicate"
Invoke-Expression $cmdReplicate