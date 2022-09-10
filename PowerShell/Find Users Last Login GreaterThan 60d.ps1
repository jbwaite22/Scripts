# Import the Active Directory Module
Import-module activedirectory
#
# Create a variable for get-date (current date)
$date = get-date
#
# Create a variable called $User to get all users in Active Directory with all Properties (This can be modified for groups, etc.)
$User = Get-ADUser -Filter 'objectclass -eq "User"' -Properties *
#
# Display all Users within Active Directory that have not logged on in the last 60 days
$User | Where-Object {$_.lastlogondate -lt $date.AddDays(-60)} |
#
# Sort the out-put data by LastLogonDate
Sort-Object -Property LastLogonDate |
#
# Display the information with the below headings
Select Displayname,Created,LastLogonDate,Enabled |
#
# Export the results to CSV file
Out-file [File Path]\UsersLast60Days.csv