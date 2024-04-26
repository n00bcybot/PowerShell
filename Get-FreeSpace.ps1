function Get-FreeSpace 
{
    param ([Parameter(Mandatory = $true)][string]$DriveLetter)
    $result = [math]::Round((Get-PSDrive $DriveLetter).Free /1GB, 2)
    Write-Output $([string]$result + "GB")
}