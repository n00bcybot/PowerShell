#--------------------------------------------------------------------#

#--------------------------------------------------------------------#


Add-Type -AssemblyName System.Windows.Forms

$formObject = [System.Windows.Forms.Form]
$labelObject = [System.Windows.Forms.Label]
$groupboxObject = [System.Windows.Forms.GroupBox]

#--------------------------------------------------------------------#

$myForm = New-Object $formObject
$myForm.ClientSize = "500, 400"
$myForm.Text = "Hello World"
$myForm.BackColor = "#ffffff"
$myForm.Margin = '5,5,5,5'
$myForm.Padding = '5,5,5,5'

$myLabel1 = New-Object $labelObject
$myLabel1.Text = "Hello world!"
$myLabel1.Font = 'Verdana, 18'
$myLabel1.AutoSize = $true
$myLabel1.Margin = '5,5,5,5'
$myLabel1.Padding = '5,5,5,5'
$myLabel1.Location = '5,5'
$myLabel1.BorderStyle = "FixedSingle"


$mygroupbox1 = New-Object $groupboxObject
$mygroupbox1.Margin = '5,5,5,5'
$mygroupbox1.Padding = '5,5,5,5'
$mygroupbox1.ClientSize = "490,390"
$mygroupbox1.Location = '5,5'

$mygroupbox2 = New-Object $groupboxObject
$mygroupbox2.Margin = '5,5,5,5'
$mygroupbox2.Padding = '5,5,5,5'
$mygroupbox2.AutoSize = $true
$mygroupbox2.Location = '5,5'

$mygroupbox2.Controls.AddRange(@(

    $myLabel1

))


$mygroupbox1.Controls.AddRange(@(

    $mygroupbox2

))


$myForm.Controls.AddRange(@(

    $mygroupbox1
    
))

#--------------------------------------------------------------------#
$myForm.ShowDialog()
$myForm.Dispose()