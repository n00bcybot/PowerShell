
function WakeOnLAN {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $MacAddress
    )
    $MacByteArray = $MacAddress -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
    [Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)
    $UdpClient = New-Object System.Net.Sockets.UdpClient
    $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7)
    $UdpClient.Send($MagicPacket,$MagicPacket.Length)
    $UdpClient.Close()
}