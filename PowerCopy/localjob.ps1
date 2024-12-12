

$SourceFolder = ""
$DestinationFolder = ""
$AllFiles = (Get-ChildItem -Path $SourceFolder -Recurse).FullName
$Threads = 6

# Create array with list of file names to copy for each physical thread on the CPU
#---------------------------------------------------------------------------------

$array = @()
foreach ($r in 1..$Threads){

   $FilesList = for ($i=$r; $i -le $AllFiles.Length; $i = $i + $Threads){
        Write-Output $AllFiles[$i -1]
    }
   $array += [pscustomobject] @{Index = $r; Source = $SourceFolder; Destination = $DestinationFolder; Files = $FilesList}
}


# Copy the files in each list concurently via jobs
#----------------------------------------------------------------------------------
 $array.Index | ForEach-Object -Parallel {
    $DestinationFolder = $using:DestinationFolder
    $array = $using:array
    $list = $array[$_ -1].Files
    Start-Job -ScriptBlock {Copy-Item $using:list -Destination $using:DestinationFolder} | Receive-Job -Wait -AutoRemoveJob
} -ThrottleLimit 24