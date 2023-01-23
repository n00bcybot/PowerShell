#The following code finds the hostnames of computers in IP addresses range. It itterates over the 4th decimal of the two addresses, then pings each address inbetween.
#Those addresses who are online, will get indexed and their hostnames will be stored in a variable for later use. This is handy, since hostnames are 
#much easier to work with, and in most cases can be used instead of IP addresses.       
            
function Get-HostNames {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
            [string]
            $ip1,
            [Parameter(Mandatory = $true)]
            [string]
            $ip2  
        )
                
    $index1 = $ip1.LastIndexOf('.') + 1                             
    $index2 = $ip2.LastIndexOf('.') + 1                             
    $suffix = ($ip1.Substring($index1))..($ip2.Substring($index2))  
    $prefix = $ip1.Substring(0,$index1)
    $ips = foreach($i in $suffix){$prefix+$i}
            
    $hostnames = New-Object System.Collections.ArrayList           
        foreach ($i in $ips) 
        {
            if ((Test-Connection $i -count 1).status -eq "Success" ){$hostnames += "$i"}
            }                                          
            $domain = $hostnames | ForEach-Object -Parallel {
                invoke-command -HostName $_ -ScriptBlock {Get-CimInstance -namespace root/cimv2 -classname CIM_ComputerSystem} -ErrorAction SilentlyContinue | sort -Descending
            }
     $domain
            
}