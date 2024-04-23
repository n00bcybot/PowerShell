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
