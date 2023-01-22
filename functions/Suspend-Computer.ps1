
function Suspend-Computer {
    [CmdletBinding()]
    param (
    [Parameter()]
    [string]
    $HostName
    )
  
    if ($HostName -ne $null){Invoke-Command -HostName $HostName -ScriptBlock {
        Add-Type -Assembly System.Windows.Forms
        $state = [System.Windows.Forms.PowerState]::Suspend
        [System.Windows.Forms.Application]::SetSuspendState($state, $false, $false) | Out-Null}
    }
    else {
        Add-Type -Assembly System.Windows.Forms
        $state = [System.Windows.Forms.PowerState]::Suspend
        [System.Windows.Forms.Application]::SetSuspendState($state, $false, $false) | Out-Null
    }
}
