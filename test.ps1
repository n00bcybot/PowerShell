
$applist = @(
    [pscustomobject]@{Name = "Maya"; Regex = "Autodesk Maya \d\d\d\d"},
    [pscustomobject]@{Name = "Python"; Regex = "Python ..... Executables *"},
    [pscustomobject]@{Name = "Adobe"; Regex = "Adobe*"},
    [pscustomobject]@{Name = "VLC"; Regex = "VLC*"},
    [pscustomobject]@{Name = "Toon Boom"; Regex = "Toon Boom*"},
    [pscustomobject]@{Name = "BlaBla"; Regex = "BlaBla*"}
)

$allresults = foreach($item in $applist) {
    
    $Wow6432Node = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $Microsoft = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    function Find-App {
    param (
        [switch]$Maya,
        [switch]$Default
    )
    if ($Maya){
        $result = Get-ChildItem $Microsoft | Get-ItemProperty | Where-Object {$_.DisplayName -Match $item.Regex} | Where-Object {$_.DisplayVersion -notmatch "^\d\d\d\d"} | Select-Object Displayname, DisplayVersion
        if (!$result){
            $result = [pscustomobject]@{DisplayName =  $item.Name; DisplayVersion = ""; Status = "Missing"}
        }else{
            $result | Add-Member -MemberType NoteProperty -Name Status -Value "Installed"
        }
        $result
    }elseif ($Default) {
        $result = Get-ChildItem $Microsoft | Get-ItemProperty | Where-Object {$_.DisplayName -Match $item.Regex} | Select-Object Displayname, DisplayVersion
        if (!$result){$result = [pscustomobject]@{DisplayName =  $item.Name; DisplayVersion = ""; Status = "Missing"}
        }else{
            $result | Add-Member -MemberType NoteProperty -Name Status -Value "Installed"
        }
        $result
    }else {
        $result = Get-ChildItem $Wow6432Node | Get-ItemProperty | Where-Object {$_.DisplayName -Match $item.Regex} | Select-Object Displayname, DisplayVersion
        if (!$result){$result = [pscustomobject]@{DisplayName =  $item.Name; DisplayVersion = ""; Status = "Missing"}
        }else{
            $result | Add-Member -MemberType NoteProperty -Name Status -Value "Installed"
        }
        $result
            }
        }
        
        switch ($item.Name){
            "Adobe" {Find-App}
            "VLC" {Find-App}
            "Toon Boom" {Find-App}
            "Maya" {Find-App -Maya}
            Default {Find-App -Default}
        }
    }

$allresults

# ----------------------------------------------------------------------------------------------------------------------------------

New-PSDrive -Name "T" -Root "\\dumpap3\tools" -PSProvider "FileSystem" -Persist
T:\_Pipeline\cobopipe_v02-001\BAT_files\update_harmony_hotbar.bat


$ttt = Get-Content -Path "C:\Users\plp\VsCodeProjects\cobopipe_v02-001\PowerShell\install_apps.json" | ConvertFrom-Json


$applist = @(
    [pscustomobject]@{Name = "Python"; Regex = "Python ..... Executables *"}
    
)
# $i is computername
# $ttt.$i is apps object
# $b is custom object from the install list
#
# for each computer in the list from the install_apps.json, created by the python script
# for each application in the applications list of the computer
# if the application is in the install list, do $b 

foreach ($i in $ttt.psobject.Properties.GetEnumerator().name){
    foreach ($j in $ttt.$i.displayname) {
        foreach ($b in $applist.name){
        if ($j -match $b){
            $("$b "+ " $i")}
        }
    }
}