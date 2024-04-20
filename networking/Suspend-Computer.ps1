
param ([Parameter(Mandatory = $true)][string]$ComputerName)

try {
     Test-Connection -TargetName $ComputerName -ErrorAction Stop | Out-Null
}
catch {
     Write-Error "$ComputerName is not responding"
     break
}
$session = New-PSSession -ComputerName $ComputerName
      
Invoke-Command -Session $session {
    Add-Type -Assembly System.Windows.Forms
    $state = [System.Windows.Forms.PowerState]::Suspend
    [System.Windows.Forms.Application]::SetSuspendState($state, $false, $false) | Out-Null
}

Get-PSsession | Remove-PSSession | Out-Null