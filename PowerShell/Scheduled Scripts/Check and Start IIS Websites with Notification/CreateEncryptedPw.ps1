
$password = "[Password to Encrypt]"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$secureStringText = $secureStringPwd | ConvertFrom-SecureString 
Set-Content "[File Path]\ExportedPassword.txt" $secureStringText