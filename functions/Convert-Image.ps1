
function Convert-Image {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][ValidateSet("Jpeg", "Png", "Tiff", "Gif")][string]$ConvertTo
    )
    try {
        $Image = Get-Item -Path $FilePath -ErrorAction Stop
    } catch {
        Write-Error "$FilePath does not exist, please check file name"
        break
    }
    
    # Load the necessary asembly
    Add-Type -AssemblyName System.Drawing
    
    # Get the file path without he expension, so a new one can be added
    $PathNoExtension = $Image.FullName.Remove($Image.FullName.LastIndexOf("."))
    
    # Create a hashtable with available extensions to check against           
    $extensions = @{Jpeg = "jpg"; Png = "png"; Tiff = "tif"; Gif = "gif";}
    
    # Loop through the hashtable
    # If there is a match between the key and the desired new format, set the key as the new file format
    foreach($extension in $extensions.Keys){ 
        if ($extension.Equals($ConvertTo)){
            try {
                $NewImagePath = $PathNoExtension + "." + $extensions[$extension]
                $NewImage = [System.Drawing.Image]::FromFile($FilePath)
                $NewImage.Save($NewImagePath, [System.Drawing.Imaging.ImageFormat]::$extension)
                
                if (Test-Path $NewImagePath){
                    Write-Output "$Image.Name successfully converted"
                } else {
                      Write-Output "$Image.Name could not be converted"
                }
            } catch {
                Write-Error "Cannot convert to the same file format"
            }
        }
    }
}
