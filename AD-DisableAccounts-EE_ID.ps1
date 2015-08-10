#
# Script Name: AD-DisableAccounts-EE_ID.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   8.11.2014


##### MAIN #####

# Get users and Employee ID from csv and filter based on EmployeeID.  Disable all users that match.

Import-Module activedirectory

$list = Import-CSV c:\scripts\disableUsers.csv

forEach ($item in $list) {

$ID = $item.EmployeeID
$Username = Get-ADUser -Filter "EmployeeID -like $ID"
$Account = $Username.samAccountName

Disable-ADAccount $Account

}