
# Get wifi password of specific profile
function Get-WiFiPassword {
param ([Parameter(Mandatory = $true)][string]$WiFiProfile)
$pass = ((netsh wlan show profile name=$WiFiProfile key="clear" | Select-String "Key Content").Line -split ": ")[1]
$pass
}

# Get all wifi profiles and enumerate 
$wifiprofiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {($_ -split ":")[1].Trim()}
Write-Output "`nAvailable WiFi profiles:`n"
foreach ($entry in $wifiprofiles){
"{0} - {1}" -f ($wifiprofiles.IndexOf($entry) +1), $entry
}

# Get user input, use index to select profile from the list and return the password for it
$input = Read-Host "`nSelect profile number to display password"
$pass = Get-WiFiPassword -WiFiProfile $wifiprofiles[$input -1]
$pass
