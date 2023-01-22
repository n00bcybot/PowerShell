Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#--------------------------------------------------------------------------
# Renaming the file
#-----------------------------------------------------------------------------
function Convert-Image {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Jpeg", "Png", "Tiff", "Gif")]
        [string]
        $ConvertTo
    )
    $imagename = $filepath.Remove($filepath.LastIndexOf("."))
    $ext = $null
       
    $extensions = @{Jpeg = "jpg"
                    Png = "png"   
                    Tiff = "tif"
                    Gif = "gif"}
        foreach($i in $extensions.Keys)
            { 
                if ($i.Equals($ConvertTo))
                {
                    $ext = $i
                    $dotext = $extensions["$i"]
                }
            }
    $image = [System.Drawing.Image]::FromFile($FilePath)
    $path = "$imagename"+"."+"$dotext"
    $image.Save($path, [System.Drawing.Imaging.ImageFormat]::$ext)            
}



