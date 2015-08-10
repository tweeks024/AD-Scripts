#
# Script Name: AD-DisableComputerAccounts.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   11.17.2014


##### MAIN #####

# Get workstations and servers from csv files, move object, and disable

Import-Module activedirectory

$workstations = Import-CSV c:\scripts\workstations.csv

forEach ($item in $workstations) {

$workstation = $item.name

Get-ADComputer $workstation | Move-ADObject -TargetPath "OU=Disabled,OU=Workstations,DC=corp,DC=com"
Disable-ADAccount "CN=$workstation,OU=Disabled,OU=Workstations,DC=corp,DC=com"
}

$servers = Import-CSV c:\scripts\servers.csv


forEach ($item in $servers) {

$server = $item.ServerName

Get-ADComputer $server | Move-ADObject -TargetPath "OU=Decommed,OU=Servers,DC=corp,DC=com"
Disable-ADAccount "CN=$server,OU=Decommed,OU=Servers,DC=corp,DC=com"
}