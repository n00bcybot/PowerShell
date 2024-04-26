try 
{
    Get-Command ffmpeg -ErrorAction Stop
    $check_code = ffmpeg -version
    $check_code[0] -match "git-(.*?)-full" | Out-Null
    $code = $Matches.1 + ":"
    $get_version = Invoke-WebRequest -Uri "https://git.ffmpeg.org/gitweb/ffmpeg.git/blob_plain/$code/RELEASE"
    $version = $get_version.Content -match "..."
    $version = $Matches.Values
    $version
}
catch 
{
    Write-Error "FFMpeg was not found in the system path"
}