# Turn on or off network discovery and file and printer sharing for different types of network profiles

Invoke-Command -ComputerName $computername -ScriptBlock {Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private}
Invoke-Command -ComputerName $computername -ScriptBlock {Set-NetFirewallRule -DisplayGroup "Network Discovery" -Profile Private -Enabled True}