param ($file, $file2)


function Choco-Search {

param (
	[Parameter(Mandatory = $true)]
	[string]$file
	)
	write-host $file 

	
}



function Winget-Search {

param (
	[Parameter(Mandatory = $true)]
	[string]$file2
	)
	
	write-host $file2
	
}
Choco-Search $file 
Winget-Search $file2
