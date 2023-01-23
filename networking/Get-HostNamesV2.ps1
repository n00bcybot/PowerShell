
function Get-HostNames {
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
$ttt = New-Object System.Collections.ArrayList
 foreach ($i in $ips) 
        {
            if ((Test-Connection $i -count 1).status -eq "Success" ){$ttt += "$i"}
            }
$domain = $ttt | ForEach-Object -Parallel {Invoke-Command -HostName $_ -ScriptBlock {(Get-NetAdapter | Where-Object "Status" -EQ "Up").SystemName}}
foreach ($i in $domain){if ($i.Contains(".")){$domain[$domain.indexof("$i")] = $i.remove($i.indexof("."))}}
$domain
}