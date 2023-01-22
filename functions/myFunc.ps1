function Gimme-Date {
    param(
	[Parameter(Mandatory = $true)]
    [string]$date
    )
    	$ttt=$null
	$number = 5
    if ($date -eq $number){$ttt = "Correct!!!"} else {$ttt = "Wrong date!!!"}
	
	return $ttt

}

Gimme-Date -date 