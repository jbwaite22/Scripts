# Specify file of computer NetBIOS names. A list of computer names must be created and added to the below directory
$File = "[File Path]\Computers.txt"

$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.PageSize = 200
$Searcher.SearchScope = "subtree"
$Searcher.SearchRoot = "LDAP://$Domain"

$Searcher.PropertiesToLoad.Add("sAMAccountName") > $Null
$Searcher.PropertiesToLoad.Add("lastLogonTimeStamp") > $Null

# Read computer names.
$Computers = (Get-Content $File)

# Filter on computers listed in file.
$Filter = "(|"
ForEach ($Computer In $Computers)
{
# sAMAccountName of computer is NetBIOS name with trailing "$" character.
  $Filter = $Filter + "(sAMAccountName=$Computer`$)"
}
$Filter = $Filter + ")"
$Searcher.Filter = $Filter

$Results = $Searcher.FindAll()
ForEach ($Result In $Results)
{
  $Name = $Result.Properties.Item("sAMAccountName")
  $LL = $Result.Properties.Item("lastLogonTimeStamp")
  If ($LL.Count -eq 0)
  {
    $Last = [DateTime]0
  }
  Else
  {
    $Last = [DateTime]$LL.Item(0)
  }
  If ($Last -eq 0)
  {
    $LastLogon = $Last.AddYears(1600)
  }
  Else
  {
    $LastLogon = $Last.AddYears(1600).ToLocalTime()
  }
  """$Name"",$LastLogon"
}