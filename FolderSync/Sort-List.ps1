
param (
    [int]$number,
    [string]$SourceFolder,
    [int]$threadCount,
    [string]$BackupFolder
     )
    $SourceList = Get-ChildItem -Path $SourceFolder
    $list = for ($i = $number; $i -le $SourceList.Length; $i = $i + $threadCount){
            $sourcePath = "$SourceFolder\$($SourceList[$i - 1].Name)"
            Copy-Item $sourcePath -Destination $BackupFolder -Recurse
        } 
   $list | ForEach-Object {write-host $_}
