
# Copy large amount of files fast
#---------------------------------------------------------------------------------

$SourceFolder = "C:\Users\fresh\"
$DestinationFolder = "G:\fresh1\"
$FilesNames = (Get-ChildItem -Path $SourceFolder).Name
$Threads = 6

# Create array with list of file names to copy for each physical thread on the CPU
#---------------------------------------------------------------------------------

$array = @()
foreach ($r in 1..$Threads){

   $FilesList = for ($i=$r; $i -le $FilesNames.Length; $i = $i + $Threads){
        Write-Output $FilesNames[$i -1]
    }
   $array += [pscustomobject] @{Index = $r; Source = $SourceFolder; Destination = $DestinationFolder; Files = $FilesList}
}

# Copy the files in each list concurently
#----------------------------------------------------------------------------------


foreach ($i in $array.Index) {

    Start-Job -ScriptBlock {
    $i = $using:i
    $array = $using:array;
    $file = $array[$i -1].Files;
    $SourceFolder = $using:SourceFolder; 
    $DestinationFolder = $using:DestinationFolder;
     Start-Process pwsh "-command robocopy $SourceFolder $DestinationFolder $file /E /IF /ZB"
    } 
}
