    $list = @()
    #Counters
    $i = 0; $j = 0
    

    #Get licensed users
    $users=get-msoluser -All | ? {$_.islicensed -eq $true}
    #total licensed users
    $count = $users.count

    foreach ($u in $users){
        $i++; $j++; 
        Write-Host "$i/$count"

        if ($j -lt 199){
            $upn = $u.userprincipalname
            $list += $upn
        }
        if ($j -gt 199){
            Request-SPOPersonalSite -UserEmails $list
            Start-Sleep -Milliseconds 655
            $list = @()
            $j = 0
        }
    }