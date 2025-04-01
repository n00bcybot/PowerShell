

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

# With thread jobs
#-------------------------------------------------------------------------------------------------------------------------


$SourceFolder = "C:\Users\fresh\Desktop\render\source"
$DestinationFolder = "C:\Users\fresh\Desktop\render\destination"
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

foreach ($entry in $array.Index) {
    
        Start-ThreadJob  -ScriptBlock {
        $array = $using:array
        $DestinationFolder = $using:DestinationFolder
        $index = $using:entry
        Copy-Item $array[$index -1].Files -Destination $DestinationFolder
    } -StreamingHost $Host
}




#-------------------------------------------------------------------------------------------------------------

function Start-RunSpace {

   param (
     $number
   )
   
   # Load required typetable
   $TypeTable = [System.Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()
   
   # Open new runspace with the typetable
   $RunSpace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateOutOfProcessRunspace($TypeTable)
   
   # Run PowerShell
   $PowerShell = [powershell]::Create()
   
   # Open the runspace
   $RunSpace.Open()
   
   # Assign the runspace to PowerShell
   $PowerShell.Runspace = $RunSpace
      
   Write-Output $RunSpace

}
   
   #-------------------------------------------------------------------------------------------------------------
   # Get all physical threads
   $Threads = (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
   
   # Create runspace for each thread
   $runspaces = foreach ($i in 1..$Threads){Start-RunSpace $i}
   
   
   foreach ($runspace in $runspaces) {
      
      $block = {
   
         $SourceFolder = "C:\Users\fresh\Desktop\render\source"
         $DestinationFolder = "C:\Users\fresh\Desktop\render\destination"
         $AllFiles = (Get-ChildItem -Path $SourceFolder -Recurse).FullName
      
         # Create array with list of file names to copy for each physical thread on the CPU
         #---------------------------------------------------------------------------------
      
         $array = @()
         foreach ($r in 1..$Threads){
      
            $FilesList = for ($i=$r; $i -le $AllFiles.Length; $i = $i + $Threads){
               Write-Output $AllFiles[$i -1]
            }
            $array += [pscustomobject]@{RunSpaceID = $runspace.Id;Index = $r; Source = $SourceFolder; Destination = $DestinationFolder; Files = $FilesList}
         }
         
         Copy-Item $array[$thread -1].Files -Destination $DestinationFolder
           
      }
   
      $PowerShell.AddScript($block)
      $PowerShell.Invoke()
      $PowerShell.Dispose()
   
   }