function Add-EnvironmentVariable {
    param (
    [Parameter(Mandatory=$true)][string]$Variable,
    [switch]$ToSystemEnvironment,
    [switch]$ToUserEnvironment,
    [switch]$AsFirstEntry
    )
    if ($ToSystemEnvironment){
         $envmachine = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
         if($AsFirstEntry){
              [Environment]::SetEnvironmentVariable("Path", $(($Variable + ";") + $envmachine), [EnvironmentVariableTarget]::Machine) 
         }else{
         [Environment]::SetEnvironmentVariable("Path", $($envmachine + $Variable), [EnvironmentVariableTarget]::Machine)
         }
    }
    if ($ToUserEnvironment){
         $envuser = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
         if($AsFirstEntry){
              [Environment]::SetEnvironmentVariable("Path", $(($Variable + ";") + $envuser), [EnvironmentVariableTarget]::User) 
         }else{
         [Environment]::SetEnvironmentVariable("Path", $($envuser + $Variable), [EnvironmentVariableTarget]::User)
         }
    }

}

# Basic remote session function with two mandatory parameters - computer name and username
#------------------------------------------------------------------------------------------------------------------------
function Enter-RemoteSession {
    param (
        [Parameter(Mandatory=$true)][string]$UserName,
        [Parameter(Mandatory=$true)][string]$ComputerName
    )
    
    # Get credentials
    $creds = Get-Credential -UserName $username
      
    # Check if there is already opened session and set the prefix as enumerator
    $prefix = ((Get-PSSession).ComputerName.count + 1)
    $index = 0
    $session = $null
    
    Write-Host "`nConnecting..."
    do { # Try and try to open
        Start-Sleep -Milliseconds 500
    # Remote session with appropriate name (computername/session/session number)
        $session = New-PSSession -Name ($ComputerName + "RS" + $prefix) -ComputerName $computername -Credential $creds
        $index += 1
    }until (
    # Until it's open
        Get-PSSession
    )
    # Option to enter the session     
    if ($session.Availability -eq 'Available' -and $session.State -eq 'Opened'){
        Write-Host "`nSuccessfully connected to $ComputerName!" -ForegroundColor Green
        $readhost = Read-Host "`nEnter session? [y/n]"
        if ($readhost -eq "Y"){
            Enter-PSSession $session
        }
        else {
            continue
        }    
    }
    else {
        Write-Host "`nCould not establish connection to $ComputerName" -ForegroundColor Red
    }
}
#------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------
function Get-HostInfo {
    param (
        [Parameter(Mandatory=$true)][string]$ComputerName,
        [switch]$IPAddress,
        [switch]$CurrentUser,
        [switch]$WinRMStatus
    )
    
    $ComputerInfo = [pscustomobject]@{
        Name        = "$ComputerName"
        IPAddress   = ""
        CurrentUser = ""
        WinRMStatus = ""
    }

    switch ($true) {
        
        $IPAddress {
            if(!($ComputerName)){
                Write-Host "Please enter host name and try again" -ForegroundColor Yellow
                break
            }else {
                try {
                    $ComputerInfo.IPAddress = [System.Net.Dns]::GetHostAddresses($ComputerName).IPAddressToString
                } catch{
                    Write-Host "No such host is known" -ForegroundColor Red
                }
            }
        }
        
        $CurrentUser {
            if(!($ComputerName)){
                Write-Host "Please enter host name and try again" -ForegroundColor Yellow
                break
            }else {
                $username = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    # if ((Get-NetFirewallRule -DisplayGroup "File and printer sharing").Disabled){
                    #     Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Profile "Domain" -Enabled True
                    # }
                $queryResults = (qwinsta /server:$ComputerName | ForEach-Object { (($_.trim() -replace '\s+',',')) } | ConvertFrom-Csv)
                foreach ($i in $queryResults){
                    if($i.STATE -eq "Active"){
                        $i.USERNAME
                    }
                } 
                }
                $ComputerInfo.CurrentUser = $username 
            }
        }
        
        $WinRMStatus {
            if(!($ComputerName)){
            Write-Host "Please enter computer name and try again" -ForegroundColor Yellow
            break
            }else {
                if (Test-WSMan -ComputerName $ComputerName -ErrorAction SilentlyContinue){
                    $ComputerInfo.WinRmStatus = "Available"
                }else {
                    Write-Host "$ComputerName unreachable" -ForegroundColor Red
                }                
            }
        }
        
        Default {          
            if (Test-WSMan $ComputerName){
                Write-Host "$ComputerName available and configured" -ForegroundColor Green
            }else {
                Write-Host "$ComputerName unreachable" -ForegroundColor Red
            }
        }
    }
    return $ComputerInfo
}


# END Get-HostInfo 
#-------------------------------------------------------------------------------------------------------------------------------------------


# Create custom object from a list of computers with the function
#-------------------------------------------------------------------------------------------------------------------------------------------

# $list = "vm2", "rs1", "vm3"
 
# $PSCustomObject = foreach ($i in $list){
#     if ((Test-Connection $i -Count 1).Status -eq "Success"){
#         Get-HostInfo -ComputerName $i -IPAddress -CurrentUser -WinRMStatus
#     }else{
#         Write-Host "$i is unreachable" -ForegroundColor Red
#     }
# }
# $PSCustomObject
#-------------------------------------------------------------------------------------------------------------------------------------------
# $InstallScriptBlock = .\InstallScriptBlock.ps1

# # List of computers to run scriptblock agains
# $ComputersList = "vm2", "vm3"

# Run the scriptblock on remote computer
# Invoke-Command -ComputerName $ComputersList -ScriptBlock $InstallScriptBlock

# Or use session to send the command 
# $creds = Get-Credential -UserName vmnet\admin
# $session = New-PSSession -ComputerName $computerslist -Credential $creds
# Invoke-Command -Session  $session -ScriptBlock $InstallScriptBlock

# function Install-App {
#     param (
#         [Parameter(Mandatory)][string[]]$ComputersList,
#         [Parameter(Mandatory)][scriptblock]$InstallScriptBlock,
#         [string]$AtTime
#     )
#     Invoke-Command -ComputerName $ComputersList -ScriptBlock $InstallScriptBlock
# }

# Install-App -ComputersList $ComputersList -InstallScriptBlock $InstallScriptBlock
#

# List of computers to run scriptblock agains
# $ComputersList = "vm2", "vm3"

function Install-App {
    param (
        [Parameter(Mandatory)][string[]]$ComputersList,
        [scriptblock]$InstallScriptBlock,
        [string]$FilePath,
        [string]$AtTime
    )
    if ($InstallScriptBlock){
        Invoke-Command -ComputerName $ComputersList -ScriptBlock $InstallScriptBlock
    } elseif ($FilePath) {
        Invoke-Command -FilePath $FilePath -ComputerName $ComputersList 
    }
    
}

# Install-App -ComputersList $ComputersList -FilePath 'C:\users\admin\desktop\InstallScriptBlock.ps1'

# or Install-App -ComputersList $ComputersList -InstallScriptBlock $InstallScriptBlock
function Remove-EnvironmentVariable {
     param (
     [Parameter(Mandatory=$true)][string]$Variable,
     [switch]$FromSystemEnvironment,
     [switch]$FromUserEnvironment
     )
     if ($FromSystemEnvironment){
          $envmachine = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
          if (($envmachine -split ";").Contains($Variable)){
            [Environment]::SetEnvironmentVariable("Path", $($envmachine.Replace($Variable, "")), [EnvironmentVariableTarget]::Machine)
          }
     }
     if ($FromUserEnvironment){
          $envuser = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
          if (($envuser -split ";").Contains($Variable)){
              [Environment]::SetEnvironmentVariable("Path", $($envuser.Replace($Variable, "")), [EnvironmentVariableTarget]::User)
          }
     }
}
#-------------------------------------------------------------------------------------------------------------------------------------------
function Rename-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$MatchString,
        [Parameter(Mandatory = $true)][string]$Directory,
        [switch]$FullPath,
        [switch]$Rename        
    )
    $items = Get-ChildItem -Path $Directory -Recurse
    $newlist = New-Object System.Collections.ArrayList
    ForEach ($item in $items){
        if($item.BaseName -match $MatchString){
            if ($FullPath){
                Write-Host "Match found in" $item.Directory.Parent.Name " - " $item.FullName
                $newlist += $item
            }else{
                Write-Host "Match found in" $item.Directory.Parent.Name
                $newlist += $item
            }
        }
    }
    
    if(!$newlist){
        Write-Host "No item matching basename `"$MatchString`" was found" -ForegroundColor Yellow
    break
    }else{
        
        $index = 0
        if ($Rename){
            $renamefile = Read-Host -Prompt "`nRename files? [y/n]"
            if ($renamefile -eq "y"){
                $name = Read-Host -Prompt "`nEnter new name"
                ForEach ($item in $items){
                    if($item.BaseName -match $MatchString){
                        $newname = $item.Directory.FullName + "\" + $name + $item.Extension
                        Rename-Item -Path $item.FullName -NewName "$newname"
                        if (Test-Path -Path $newname){
                        $index += 1
                        }
                    }
                }
                Write-Host "`n"$index "out of"$newlist.Count "items successfully renamed!" -ForegroundColor Green
            }
        }
    }
    return $newlist.Directory.Parent.FullName | Sort-Object | Get-Unique
}
# END Rename-File
#-------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------
function Set-SecurityLevel{
    param (
        [switch]$High,
        [switch]$Low
    )
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if ($High -and $Low){
        Write-Host "Conflicting parameters. Choose either 'High' or 'Low'" -ForegroundColor Red
    }else {
        if ($Low){
            Set-ExecutionPolicy Bypass -Confirm:$False
            New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorAdmin' -Value 0 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'EnableLUA' -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'EnableVirtualization' -Value 0 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'PromptOnSecureDesktop' -Value 0 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'FilterAdministratorToken' -Value 0 -PropertyType DWORD -Force | Out-Null
            Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3' -Name 1806 -Value 0
        }
        elseif ($High){
            Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3' -Name 1806 -Value 1
            New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorAdmin' -Value 5 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorUser' -Value 3 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'EnableInstallerDetection' -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'EnableLUA' -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'EnableVirtualization' -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'PromptOnSecureDesktop' -Value 1 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'ValidateAdminCodeSignatures' -Value 0 -PropertyType DWORD -Force | Out-Null
            New-ItemProperty -Path $path -Name 'FilterAdministratorToken' -Value 0 -PropertyType DWORD -Force | Out-Null
            Set-ExecutionPolicy Restricted -Confirm:$false
        }
    }
}
# END Set-SecurityLevel
#-------------------------------------------------------------------------------------------------------------------------------------------
