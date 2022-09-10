#script to start iis sites on local machine
Import-Module WebAdministration
set-Location IIS:\Sites

$ApplicationSites = dir
Write-Host "Site Status"

#setup the credential object for use in send-mailmessage
$username = "[domain\IISAdminUser]"
$pwdTxt = Get-Content "[Directory Path]\ExportedPassword.txt"
$securePwd = $pwdTxt | ConvertTo-SecureString 
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd

foreach ($item in $ApplicationSites)
{
    $ApplicationSiteName = $item.Name
    $ApplicationSiteStatus = $item.state
    Write-Host "$ApplicationSiteName -> $ApplicationSiteStatus"


    if($ApplicationSiteStatus -ne "Started" -And $ApplicationSiteName -eq "[Website Name]")
    {
        Write-Host "-----> $ApplicationSiteName found stopped."
        Start-WebSite -Name $ApplicationSiteName
        Write-Host "-----> $ApplicationSiteName started."
        $Now = Get-Date -Format g

        Try{
        Send-MailMessage -To "[Send to Contact <email@address.com>]" -From "[NotificationEmailName <email@address.com>]"  -Subject "$ApplicationSiteName Site was stopped" -Credential [Email account name] -UseSsl -SmtpServer "[Mail Server]" -Body "The $ApplicationSiteName site was stopped. It was started at $now"  -Credential $credObject
        }
        Catch {
        $_ | Out-File [LogFile Path]\error.log
        }

    }
}

#script to start iis app pool on local machine

set-Location IIS:\AppPools
Write-Host "App Pool Status"
$ApplicationPools = dir
foreach ($item in $ApplicationPools)
{
$ApplicationPoolName = $item.Name
$ApplicationPoolStatus = $item.state
Write-Host "$ApplicationPoolName -> $ApplicationPoolStatus"


    if($ApplicationPoolStatus -ne "Started" -And $ApplicationPoolName -eq "TestXVVision")
    {
        Write-Host "-----> $ApplicationPoolName found stopped."
        Start-WebAppPool -Name $ApplicationPoolName
        Write-Host "-----> $ApplicationPoolName started."

        $Now = Get-Date -Format g
        Send-MailMessage -To "[Send to Contact <email@address.com>]" -From "[NotificationEmailName <email@address.com>]" -Subject "$ApplicationPoolName App Pool was stopped" -Credential [Email account] -UseSsl -SmtpServer "server-ex1" -Body "The $ApplicationPoolName app pool was stopped. It was started at $now"  -Credential $credObject 5>>"[Log file path]\error.log"

    }


}

