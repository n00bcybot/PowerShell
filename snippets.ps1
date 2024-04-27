# ------------------------------------------------------------------------------------------------------------------------------
# Silent PowerShell web install
# ------------------------------------------------------------------------------------------------------------------------------

Invoke-Expression "& { $(Invoke-RestMethod "https://aka.ms/install-powershell.ps1") } -UseMSI -quiet"

# ------------------------------------------------------------------------------------------------------------------------------
# Dynamic switch
# ------------------------------------------------------------------------------------------------------------------------------

$SwitchList | ForEach-Object {
    Write-Host "Choice"$([int]$SwitchList.IndexOf($_) + 1)":"  $SwitchList.name[$SwitchList.IndexOf($_)]
}
$var = Read-Host -Prompt "Enter switch number"
foreach ($i in $SwitchList){
    switch ($var){
        ([int]$SwitchList.IndexOf($i) + 1) {$SwitchList.name[$SwitchList.IndexOf($i)]}
    }
}

# ------------------------------------------------------------------------------------------------------------------------------
# Capture stdout into variable or print it out to the console. Starting process this way allows for sending the output to form
#-------------------------------------------------------------------------------------------------------------------------------

$OutputDir = "\\fresh1\render\render"
$StartFrame = 1
$EndFrame = 1
$step = 1
$CameraName = "persp"
$FilePath = "\\fresh1\render\test.ma"

# Create the job (Maya)
$job = "Render -r arnold -rd $OutputDir -s $StartFrame -e $EndFrame -cam $CameraName $FilePath"

$ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$ProcessStartInfo.FileName = "pwsh"
$ProcessStartInfo.Arguments =  "-command $job"
$ProcessStartInfo.UseShellExecute = $false
$ProcessStartInfo.RedirectStandardOutput = $true 

$Process = [System.Diagnostics.Process]::Start($ProcessStartInfo)

while (!$Process.HasExited){
    $readline = $Process.StandardOutput.ReadLine()
    if ($readline -ne ""){
        Write-Output $readline
    }
}


# Start rendering process. 

$OutputDir = "\\fresh1\render\render"
$CameraName = "persp"
$FilePath = "\\fresh1\render\test.ma"
$index = 1

do {
    $job = Start-Job -Name "job_$index" -ScriptBlock {
        
        param($startframe, $endframe)

        $job = "-r arnold -rd $OutputDir -s $StartFrame -e $EndFrame -cam $CameraName $FilePath"
        
        # Using dotnet to innitiate the process, since it provides more control, particularly stdin and stdout std Here, the original 
        # idea was to spawn pwsh process, which kicks off the rendring, with the hope to use it as a daemon. Unfortunatelly, after 
        # receiving the standard output in the console that this script is running from, it doesn't release the console. It works 
        # fine with Start-Job. Another benefit of using dotnet for starting the process is being able to set affinity via
        # $ProcessStartInfo, in a way that you can send particular job to particular processor core
        #---------------------------------------------------------------------------------------------------------------------------
        $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessStartInfo.FileName = "render"
        $ProcessStartInfo.Arguments = $job
        $ProcessStartInfo.UseShellExecute = $false
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.RedirectStandardError = $true
        $ProcessStartInfo.RedirectStandardInput = $true
        $Process = [System.Diagnostics.Process]::Start($ProcessStartInfo)
        
        # This while loop ensure that each line from stdout is printed as soon as it is generated. The idea here was to be able 
        # to send the output to a texbox in the interface. With the current setup (with Start-Job), this may not be possible,
        # but it might be not necessary anyway.
        #---------------------------------------------------------------------------------------------------------------------------
        while (!$Process.HasExited) {
            $stdout = $Process.StandardOutput.ReadLine()
            if ($stdout -ne ""){$stdout}
            }

    } -ArgumentList $index,$index 

    # Here the Wait-Job is used to run the jobs sequentially, as in, waiting for one job to finish, before another starts.
    # Without it, the loop will create jobs for all the numbers between the number $index is set to and the number in the
    # "until" condition. The idea of waiting for each job is to be able to send each job to whichever node on the network
    # is not already busy rendering. This slows down the whole process, but it might be the optimal approach, since
    # it allows for greater control. The other method would be to split the pool of jobs between the nodes, based on
    # the number of cores in each one and running a list of jobs on each computer. This would work perfectly fine
    # if all nodes have identical or close to the same hardware, nut if not, then likely not all jobs will be completed
    # around the same time, which may or may not be desirable 
    while ($job.State -eq "Running"){Wait-job -Name "job_$index"}
    $index++


} until ($index -eq 6)


#------------------------------------------------------------------------------------------------------------

$nodeslist =  "fresh2", "fresh3"
$sessions = @()
$OutputDir = "\\fresh1\render\render"
$FilePath = "\\fresh1\render\test.ma"
$StartFrame = 1
$EndFrame = 5
$CameraName = "persp"

$jobpool = [System.Collections.ArrayList]::new()
foreach ($frame in $StartFrame..$EndFrame){
$jobpool.Add("render -r arnold -rd $OutputDir -s $frame -e $frame -cam $CameraName $FilePath") | Out-Null
}

$creds = Get-Credential -UserName fresh

foreach ($node in $nodeslist){

    $session = New-PSSession -ComputerName $node -Credential $creds
    $sessions += $session
}
#>
do {
foreach ($session in $sessions){

    if (!(Invoke-Command -Session $session -ScriptBlock {Get-Process -Name "render" -ErrorAction SilentlyContinue})){
        $job = $jobpool[0]
        Invoke-Command -Session $session -ScriptBlock {
           
            New-PSDrive -Name "R" -PSProvider FileSystem -Root "\\fresh1\render" -Credential $using:creds -ErrorAction SilentlyContinue | Out-Null
            $job = $using:job
            Write-Output "Starting $job on $env:COMPUTERNAME"
          $renderjob = Start-Job -Name $("job_$using:StartFrame") -ScriptBlock {Start-Process pwsh "-command $using:job" -NoNewWindow -RedirectStandardOutput "\\fresh1\render\render\log_$env:COMPUTERNAME.txt"}
            
        }
        $computername = Invoke-Command -Session $session -ScriptBlock {$env:COMPUTERNAME}
        $log = Get-Content -Path "\\fresh1\render\render\log_$computername.txt"
        foreach($line in $log){if ($line -ne ""){Write-Output $line}}
        
        $jobpool.Remove($jobpool[0])
        Start-Sleep 2

     } else {
           continue
       }
}
} until ($jobpool.Count -eq 0)

#-------------------------------------------------------------------------------------------------------



# Use computers on the same subnet to copy files to shared storage folder
#--------------------------------------------------------------------------

# Get credentials to open session to all nodes
# -----------------------------------------------------------------------
$creds = Get-Credential -UserName fresh

# Load list of nodes from file or variable
#------------------------------------------------------------------------
$NodeList = $null
$NodeList = "fresh1", "fresh2"

# Get the number of threads for each machine and store them in a PSObject
# -----------------------------------------------------------------------
#
$NodeThreads = @()
$TotalThreadCount = $null
$sessions = @()
$index = 0
foreach ($node in $NodeList){

    $session = New-PSSession -ComputerName $node -Credential $creds
    $sessions += $session


   $ThreadCount = Invoke-Command -Session $session -ScriptBlock {
    
          (Get-CimInstance -ClassName Win32_Processor).NumberOfCores
    }
    foreach ($i in 1..$ThreadCount){
        $index++
        $member = [pscustomobject]@{Index= $index; LocalIndex = $i; Node = $node}
        $NodeThreads += $member
    }
        $TotalThreadCount += $ThreadCount
}
#

$Count = 1..$TotalThreadCount
$SourceFolder = "\\fresh1\render\Veeam\source"
$BackupFolder = "\\fresh1\render\Veeam\backup"
$LogFolder = "\\fresh1\render\Veeam\logs"
$SourceList = Get-ChildItem -Path $SourceFolder 

#------------------------------------------------------------------------------------------------
# Splitting the list over the total amount of threads
#-------------------------------------------------------------------------------------------------

function Make-Lists {
param (
    [int]$number,
    [string]$SourceFolder,
    [int]$threadCount,
    [string]$BackupFolder
)

$SourceList = Get-ChildItem -Path $SourceFolder
for ($i = $number; $i -le $SourceList.Length; $i = $i + $threadCount){
    $sourcePath = "$SourceFolder\$($SourceList[$i - 1].Name)"
    $backupPath = "$BackupFolder\$($SourceList[$i - 1].Name)"
    Write-Output $sourcePath
    
    } 

}
#----------------------------------------------------------------------------------------------------------
# Make the lists
# ---------------------------------------------------------------------------------------------------------

$array = @()
foreach ($num in $NodeThreads.Index){

        $list = Make-Lists -number $num -SourceFolder $SourceFolder -threadCount $TotalThreadCount -BackupFolder $BackupFolder
        
        $node = $NodeThreads[$num - 1].node
        $array += [pscustomobject]@{Index = $num; Node = $node; List = $list}
    
}

Invoke-Command -Session $sessions -ScriptBlock {
   
    New-PSDrive -Name "R" -PSProvider FileSystem -Root "\\fresh1\render" -Credential $using:creds -ErrorAction SilentlyContinue | Out-Null
    
   
    $array = $using:array
    $localArray = $array | Where-Object {$_.Node -eq $env:COMPUTERNAME} | select List, Index
    
    $block = {
        param($List, $Folder)
        Copy-Item $list -Destination $Folder -Recurse
    }
Measure-Command {
   foreach ($item in $localArray.Index){
       Start-Job $block -ArgumentList @($array[$item -1].List, $using:BackupFolder) | Wait-Job
   }}
}