function Enter-RemoteSession {
    [CmdletBinding()]
    param (
        [string]$username = (Read-Host -Prompt "Enter username"),
        [string]$computername = (Read-Host -Prompt "Connect to computer")
        )

$login = $computername + '\' + $username
$creds = Get-Credential -UserName $login
$session = New-PSSession -ComputerName $computername -Credential $creds
$sessionname = Get-PSSession -Name $session.Name
$sessionname
$sessionid = $session.Id
write-host "`n"

if ($sessionid -ne $null){
$entersession = Read-Host -Prompt " Enter session? [Y/N]"

if ("Y" -in $entersession) {
    write "`n"
    write "Connecting..."
    Enter-PSSession $session
    if (Test-Connection $computername){write "Connected!"}
    }elseif ("Y" -notin $entersession){
           write-host "`n"
           write " Session $sessionid with host `"$computername`" is open!"
          }
    }
}

