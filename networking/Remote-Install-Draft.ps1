

function Get-Something {
    param(
        [System.Management.Automation.Credential()]$Name,
        [System.Management.Automation.PSCredential()]$Credential, 
        [ValidateNotNull()],
        )
    
    
    
    }

$creds = Get-Credential -UserName "vmnet\administrator"
$session = New-PSSession -ComputerName vm2 -Credential $creds
Invoke-Command -Session $session -ScriptBlock {
$creds = Get-Credential -UserName "vmnet\administrator"
New-PSDrive -Name "T" -Root "\\rs1\dumpap3" -PSProvider "FileSystem" -Credential $creds -Persist
Start-Sleep 1
start "\\rs1\dumpap3\firefox.exe" -ArgumentList "/S"
}






$computers = (Get-ADComputer -Filter *).name
$creds = Get-Credential -UserName "vmnet\admin"

foreach($i in $computers){

Invoke-Command -ComputerName $i -ScriptBlock {
$drive = "T"
New-PSDrive -Name $drive -Root "\\rs1\dumpap3" -PSProvider "FileSystem" -Credential $using:creds -Persist
Start-Sleep 1
start "\\rs1\dumpap3\firefox.exe" -ArgumentList "/S" -Wait
Remove-PSDrive $drive -Force
    }
}