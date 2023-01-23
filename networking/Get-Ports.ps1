$ports = 20..1000
function Get-Ports {
$ports | ForEach-Object -Parallel {if ((Test-NetConnection -ComputerName fresh2 -Port $_).TcpTestSucceeded -eq "True"){$openports += $_}
$openports}
}