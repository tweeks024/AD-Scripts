#
# Script Name: AD-Set-Attribute.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   8.12.2011


##### MAIN #####

# Import users from csv and update extensionAttribute15 from values in csv.


$userlist = Import-CSV c:\scripts\users.csv

foreach ($item in $userlist) {

$display = $item.display
$jdeuser = $item.jdeuser

set-qaduser -Identity $item.display -ObjectAttributes @{extensionAttribute15=$item.jdeuser;}
get-qaduser -Identity $item.display -IncludeAllProperties | FL extensionAttribute15

}