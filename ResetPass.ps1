$UserFile = Import-csv -Path "C:\Scripts\UserWithPass.CSV"
Foreach ($AllItems in $UserFile)
{
$SamAccountName = $AllItems.SamAccountName
$ThisPassword = $AllItems.Password
Set-ADAccountPassword –Identity $SamAccountName –Reset –NewPassword (ConvertTo-SecureString -AsPlainText "$ThisPassword" -Force)
Set-ADUser -Identity $SamAccountName -ChangePasswordAtLogon $true
"$SamAccountName Complete"
}