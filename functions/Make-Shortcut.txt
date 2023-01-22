
function Make-Shortcut {
    [CmdletBinding()]
    param (
        [string]$filePath = (Read-Host -Prompt "Path to file"),
        [string]$shortcutFolder = (Read-Host -Prompt "Spawn at this location"),
        [string]$basename = (Read-Host -Prompt "Shortcut name"),
        [string]$arguments = (Read-Host -Prompt "Arguments")
    )


$fileName = $filePath.Substring($filePath.LastIndexOf("\") + 1)
$shortcutPath = $shortcutFolder + "\" + $basename + '.lnk'
$workdir = $filePath -replace "$fileName" -replace ""

$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $filePath
$shortcut.Arguments = $arguments
$shortcut.WorkingDirectory = $workdir
$shortcut.Save()
}

#-------------------------------------------------------------------------
# With PSCustomObject
#-------------------------------------------------------------------------

$shortarray = @( 
    
    [pscustomobject]@{FilePath = "C:\Program Files\PowerShell\7\pwsh.exe"; ShortcutFolder = "C:\Users\fresh\Desktop"; ShortcutName = "PowerShell 7"; Arguments = "-asda"}
    [pscustomobject]@{FilePath = "C:\WINDOWS\system32\cmd.exe"; ShortcutFolder = "C:\Users\fresh\Desktop"; ShortcutName = "Windows Command"; Arguments = "-asdsaasd"}

)

#-------------------------------------------------------------------------------

function Make-Shortcut {

    [CmdletBinding()]
    param (
     
      [PSCustomObject]$parameters      

    )


$fileName = $parameters.FilePath.Substring($parameters.FilePath.LastIndexOf("\") + 1)
$shortcutPath = $parameters.ShortcutFolder + "\" + $parameters.ShortcutName + '.lnk'
$workdir = $parameters.FilePath -replace '$fileName' -replace "" 

$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $parameters.FilePath
$shortcut.Arguments = $parameters.Arguments
$shortcut.WorkingDirectory = $workdir
$shortcut.Save()
}

#------------------------------------------------------------------------------------

foreach ($i in $shortarray){
$parameters = $i 
Make-Shortcut $parameters
}
