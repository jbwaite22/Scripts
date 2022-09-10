#Import the Active Directory Module:
Import-module activedirectory  
 
#Import the list from the user as well as define object variables:
$Users = Import-Csv -Path '[File Path]\NewStaff.csv'
foreach ($User in $Users)
{   
    #Variables:
    $Displayname =  $User.Firstname + " " + $User.Lastname
    $UserFirstname = $User.Firstname
    $UserFirstIntial = $UserFirstname.Substring(1,1)
    $UserLastname = $User.Lastname
    $OU = "OU=Staff,DC=contoso,DC=com"
    $SAM = $User.Username
    $UPN = $SAM + "@contoso.com"
    $EMAIL = $UPN"
    $Password = $User.Password
    $Path = "[User Folder parent location]\$SAM"
    $ACLUser = New-Object System.Security.Principal.NTAccount ($SAM)
    $ACLAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule ("BUILTIN\Administrators","FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow")
    $ACLOwn = New-Object System.Security.AccessControl.FileSystemAccessRule ("$ACLUser", "FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow")
    $ACLDAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule ("MHL\Domain Admins","FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow")
    $ACLSYS = New-Object System.Security.AccessControl.FileSystemAccessRule ("SYSTEM","FullControl”,”ContainerInherit,ObjectInherit”,”None”,”Allow")

    #Creation of the account with the requested formatting:
    New-ADUser -Name $Displayname -GivenName $User.Firstname -Surname $User.Lastname -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -EmailAddress $Email -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $True –PasswordNeverExpires $false -server DC.contoso.com

    #Add User to Groups:
    Add-ADGroupMember -Identity "Office365 Access" -Members $SAM

    #Create User Folders:
    New-Item -ItemType Directory -Path "$Path" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\Desktop" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\Documents" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\Videos" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\Favorites" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\Music" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\Pictures" | Out-Null
          #New-Item -ItemType Directory -Path "$Path\History" | Out-Null
      
    #Create Folder Permissions:
    #Set Main User Directory Permissions and Ownership.
    $ACL = Get-Acl -Path $Path
    $ACL.SetAccessRuleProtection($true, $false)
    $ACL.SetOwner($ACLUser)
    $ACL.AddAccessRule($ACLAdmin)
    $ACL.AddAccessRule($ACLOwn)
    $ACL.AddAccessRule($ACLDAdmin)
    $ACL.AddAccessRule($ACLSYS)
        Set-Acl -Path $Path -AclObject $ACL
   
    #For outpot Verification once complete:
    $Displayname + " has been successfully created."
}