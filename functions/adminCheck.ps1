function Test-Admin {
    
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

<# 
param([switch]$Elevated)
if ((Test-Admin) -eq $false){
    if ($elevated) {
    } else {
        Start-Process pwsh -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition)) -WorkingDirectory "C:\Windows\System32\WindowsPowerShell\v1.0\"
    }
#>   
