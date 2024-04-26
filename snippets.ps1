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