###---------------------------------------------------------------------------------
### Calling libraries
###---------------------------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Remove-Variable * -ErrorAction SilentlyContinue                                                                       # Zeroes all variables

###---------------------------------------------------------------------------------
### Functions
###---------------------------------------------------------------------------------
function Render-Job {

    param(
        $mul,
        $con,
        $seq,
        $gpu
  )


  $mul.foreach({$_ | Out-File -Append -FilePath "$output_dir\commandLine.log"})
  ForEach($i in $mul){Start-Process pwsh.exe "-command $i" -WindowStyle Hidden}

  $con | Out-File -Append -FilePath "$output_dir\commandLine.log"
  Start-Process pwsh.exe "-command $con" -WindowStyle Hidden

  $seq | Out-File -Append -FilePath "$output_dir\commandLine.log"
  Start-Process pwsh.exe "-command $seq" -WindowStyle Hidden

  $gpu | Out-File -Append -FilePath "$output_dir\commandLine.log"
  Start-Process pwsh.exe "-Command $gpu" -WindowStyle Hidden
}


    $cpu_name = ((Get-CimInstance -Class CIM_Processor).Name)
    $cpu_cores = ((Get-CimInstance -Class CIM_Processor).NumberOfCores)
    $cpu_threads = ((Get-CimInstance -Class CIM_Processor).NumberOfLogicalProcessors)
    
    $CPU = "$cpu_name, $cpu_cores cores, $cpu_threads threads processor"
    $GPU =(Get-CimInstance CIM_VideoController).Name
   
###-----------------------------------------------------------------------GUI START----------------------------------------------------------------------------------------  
###---------------------------------------------------------------------------------
### Initiating form
###---------------------------------------------------------------------------------
$fore_color = "white"
$back_color = "#538da6"

$render_form = New-Object System.Windows.Forms.Form
$render_form.ClientSize = New-Object System.Drawing.Point (550,400)
$render_form.StartPosition = "CenterScreen"
$render_form.Text = "Render Manager"
$render_form.TopMost = $false
$render_form.FormBorderStyle = "FixedDialog"
$render_form.BackColor = '#0e2a36'
$render_form.MaximizeBox = $false


#---------------------------------------------------------------------
# INPUT GROUPBOX
#---------------------------------------------------------------------

    $input_groupbox = New-Object System.Windows.Forms.Panel
    $input_groupbox.Location = '5,5'
    $input_groupbox.Size = '540,170'
    $input_groupbox.BorderStyle = 'FixedSingle'
        
        #--------------------------------------------------------------------
        #                            LABELS
        #-------------------------------------------------------------------- 
        #--------------------------------------------------------------------
        # Label 1 Select renderable file
        #--------------------------------------------------------------------
        $label_render_file = New-Object System.Windows.Forms.Label
        $label_render_file.Text = 'Select file:'
        $label_render_file.Size = '120,20'
        $label_render_file.Location = '15,10'
        $label_render_file.ForeColor = $fore_color
        $label_render_file.BorderStyle = 'None'
        $label_render_file.TextAlign = 'BottomLeft'
        $label_render_file.AutoSize = $true
        #--------------------------------------------------------------------
        # Label 2 Select renderable file
        #--------------------------------------------------------------------
        $label_output_folder = New-Object System.Windows.Forms.Label
        $label_output_folder.Text = 'Output folder:'
        $label_output_folder.Size = '120,20'
        $label_output_folder.Location = '15,35'
        $label_output_folder.ForeColor = $fore_color
        $label_output_folder.BorderStyle = 'None'
        $label_output_folder.TextAlign = 'BottomLeft'
        $label_output_folder.AutoSize = $true
        #--------------------------------------------------------------------
        # Label 3 Camera name
        #--------------------------------------------------------------------
        $label_camera = New-Object System.Windows.Forms.Label
        $label_camera.Text = 'Camera name:'
        $label_camera.Size = '120,20'
        $label_camera.Location = '15,60'
        $label_camera.ForeColor = $fore_color
        $label_camera.BorderStyle = 'None'
        $label_camera.TextAlign = 'BottomLeft'
        $label_camera.AutoSize = $true

        #--------------------------------------------------------------------
        # Label 4 Start frame
        #--------------------------------------------------------------------
        $label_startframe = New-Object System.Windows.Forms.Label
        $label_startframe.Text = 'Start frame:'
        $label_startframe.Size = '120,20'
        $label_startframe.Location = '15,85'
        $label_startframe.ForeColor = $fore_color
        $label_startframe.BorderStyle = 'None'
        $label_startframe.TextAlign = 'BottomLeft'
        $label_startframe.AutoSize = $true
        #--------------------------------------------------------------------
        # Label 5 End frame
        #--------------------------------------------------------------------
        $label_endframe = New-Object System.Windows.Forms.Label
        $label_endframe.Text = 'End frame:'
        $label_endframe.Size = '120,20'
        $label_endframe.Location = '15,110'
        $label_endframe.ForeColor = $fore_color
        $label_endframe.BorderStyle = 'None'
        $label_endframe.TextAlign = 'BottomLeft'
        $label_endframe.AutoSize = $true

        #--------------------------------------------------------------------
        # Label 6 Non-consequtive sequence
        #--------------------------------------------------------------------
        $label_sequence = New-Object System.Windows.Forms.Label
        $label_sequence.Text = 'Sequence:'
        $label_sequence.Size = '120,20'
        $label_sequence.Location = '15,140'
        $label_sequence.ForeColor = $fore_color
        $label_sequence.BorderStyle = 'None'
        $label_sequence.TextAlign = 'BottomLeft'
        $label_sequence.AutoSize = $true


        #--------------------------------------------------------------------
        #                            TEXTBOXES
        #-------------------------------------------------------------------- 
        #-------------------------------------------------------------------- 
        # Textbox 1 Get file name
        #--------------------------------------------------------------------
        $textbox_render_file = New-Object System.Windows.Forms.TextBox
        $textbox_render_file.Size = '290,10'
        $textbox_render_file.Location = '100,10'
        $textbox_render_file.BorderStyle = 'FixedSingle'
        $textbox_render_file.BackColor = $back_color
        $textbox_render_file.ForeColor = $fore_color 

        #-------------------------------------------------------------------- 
        # Textbox 2 Get output folder
        #--------------------------------------------------------------------
        $textbox_folder = New-Object System.Windows.Forms.TextBox
        $textbox_folder.Size = '290,10'
        $textbox_folder.Location = '100,35'
        $textbox_folder.BorderStyle = 'FixedSingle'
        $textbox_folder.BackColor = $back_color
        $textbox_folder.ForeColor = $fore_color
        
        #-------------------------------------------------------------------- 
        # Textbox 3 Get camera name
        #--------------------------------------------------------------------
        $textbox_camera = New-Object System.Windows.Forms.TextBox
        $textbox_camera.Size = '60,10'
        $textbox_camera.Location = '100,60'
        $textbox_camera.BorderStyle = 'FixedSingle'
        $textbox_camera.BackColor = $back_color
        $textbox_camera.ForeColor = $fore_color

        #-------------------------------------------------------------------- 
        # Textbox 4 Start frame number
        #--------------------------------------------------------------------
        $textbox_startframe = New-Object System.Windows.Forms.TextBox
        $textbox_startframe.Size = '60,10'
        $textbox_startframe.Location = '100,85'
        $textbox_startframe.BorderStyle = 'FixedSingle'
        $textbox_startframe.BackColor = $back_color
        $textbox_startframe.ForeColor = $fore_color

        #-------------------------------------------------------------------- 
        # Textbox 5 End frame number
        #--------------------------------------------------------------------
        $textbox_endframe = New-Object System.Windows.Forms.TextBox
        $textbox_endframe.Size = '60,10'
        $textbox_endframe.Location = '100,110'
        $textbox_endframe.BorderStyle = 'FixedSingle'
        $textbox_endframe.BackColor = $back_color
        $textbox_endframe.ForeColor = $fore_color
        
        #-------------------------------------------------------------------- 
        # Textbox 6 Sequence
        #--------------------------------------------------------------------
        $textbox_seq = New-Object System.Windows.Forms.TextBox
        $textbox_seq.Size = '150,10'
        $textbox_seq.Location = '100,140'
        $textbox_seq.BorderStyle = 'FixedSingle'
        $textbox_seq.BackColor = $back_color
        $textbox_seq.ForeColor = $fore_color  

        #--------------------------------------------------------------------
        #                            BUTTONS
        #-------------------------------------------------------------------- 
        #--------------------------------------------------------------------
        # Button 1 Select file
        #-------------------------------------------------------------------- 
        $select_file_button = New-Object System.Windows.Forms.Button
        $select_file_button.Text = "Browse"
        $select_file_button.Location = '400,9'
        $select_file_button.Size = '50,22'
        $select_file_button.ForeColor = $fore_color
        $select_file_button.AutoSize = $true

        #--------------------------------------------------------------------
        # Button 1 Open file dialog
        #-------------------------------------------------------------------- 
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.Filter = 'Maya Files (*.ma)|*.ma|Maya Files (*.mb)|*.mb'

        #--------------------------------------------------------------------
        # Button 1 Add click event
        #-------------------------------------------------------------------- 
        $select_file_button.Add_Click({

            $OpenFileDialog.ShowDialog()
            $textbox_render_file.Text = $OpenFileDialog.FileName
            $sub_filename = $OpenFileDialog.SafeFileName
            $log_filename_textbox.Text = $sub_filename.Substring(0,$sub_filename.Length -3)
        })
        
        #--------------------------------------------------------------------
        # Button 2 Select folder
        #-------------------------------------------------------------------- 
        $select_folder_button = New-Object System.Windows.Forms.Button
        $select_folder_button.Text = "Browse"
        $select_folder_button.Location = '400,34'
        $select_folder_button.Size = '50,22'
        $select_folder_button.ForeColor = $fore_color
        $select_folder_button.AutoSize = $true
        #--------------------------------------------------------------------
        # Button 2 Folder browser dialog
        #-------------------------------------------------------------------- 
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

        #--------------------------------------------------------------------
        # Button 2 Add click event
        #-------------------------------------------------------------------- 
        $select_folder_button.Add_Click({

        $folderBrowser.ShowDialog()
        $textbox_folder.Text = $folderBrowser.SelectedPath          
        })

    $input_groupbox.Controls.AddRange(@(
    
        $label_render_file,
        $label_output_folder,
        $label_camera,
        $label_startframe,
        $label_endframe,
        $textbox_render_file,
        $textbox_folder,
        $textbox_camera,
        $textbox_startframe,
        $textbox_endframe,
        $select_file_button,
        $select_folder_button,
        $label_sequence,
        $textbox_seq
    
    ))


#---------------------------------------------------------------------
# PROCESSING UNIT GROUPBOX
#---------------------------------------------------------------------

    $processor_groupbox = New-Object System.Windows.Forms.Panel
    $processor_groupbox.Location = '5,180'
    $processor_groupbox.Size = '540,60'
    $processor_groupbox.BorderStyle = 'FixedSingle'
            
        
        #--------------------------------------------------------------------
        #                            LABELS
        #--------------------------------------------------------------------
        #-------------------------------------------------------------------- 
        # Label 6 Processing unit
        #-------------------------------------------------------------------- 
        $select_device_label = New-Object System.Windows.Forms.Label
        $select_device_label.Text = 'Processing unit:'
        $select_device_label.Size = '120,20'
        $select_device_label.Location = '15,0'
        $select_device_label.ForeColor = $fore_color
        $select_device_label.BorderStyle = 'None'
        $select_device_label.TextAlign = 'BottomLeft'
        $select_device_label.AutoSize = $true

        #-------------------------------------------------------------------- 
        # Label 7 Dropdown threads
        #-------------------------------------------------------------------- 
        $thread_label = New-Object System.Windows.Forms.Label
        $thread_label.Text = 'Number of threads:'
        $thread_label.Size = '160,20'
        $thread_label.Location = '340,0'
        $thread_label.ForeColor = $fore_color
        $thread_label.BorderStyle = 'None'
        $thread_label.TextAlign = 'BottomLeft'
        
        
        #--------------------------------------------------------------------
        #                            COMBOBOX
        #--------------------------------------------------------------------
        #--------------------------------------------------------------------
        # Combobox 1 Select device                           
        #--------------------------------------------------------------------
        $select_device = New-Object System.Windows.Forms.ComboBox             
        $select_device.DropDownStyle = 'DropDownList'
        $select_device.Location = '15,25'
        $select_device.Size = '410,20'
        $select_device.Items.AddRange(@("$CPU","$GPU"))
        $select_device.SelectedItem = "$CPU"
        $select_device.FlatStyle = 'Flat'
        $select_device.ForeColor = $fore_color
        $select_device.BackColor = $back_color
        
         
        #--------------------------------------------------------------------
        #                         THREAD DROPDOWN
        #--------------------------------------------------------------------
        $cpu_threads = $global:cpu_threads..1
        
        $thread_dropdown = New-Object System.Windows.Forms.ComboBox             
        $thread_dropdown.DropDownStyle = 'DropDownList'
        $thread_dropdown.Location = '430,25'
        $thread_dropdown.Size = '35,22'
        $thread_dropdown.Items.AddRange(@($cpu_threads))
        $thread_dropdown.SelectedItem = $cpu_threads[0]
        $thread_dropdown.FlatStyle = 'Flat'
        $thread_dropdown.BackColor = $back_color
        $thread_dropdown.ForeColor = $fore_color
        


    $processor_groupbox.Controls.AddRange(@(

        $select_device_label,
        $select_device,
        $thread_label,
        $global:thread_dropdown
    ))
   
#---------------------------------------------------------------------
# RADIO GROUPBOX
#---------------------------------------------------------------------

    $radio_groupbox = New-Object System.Windows.Forms.Panel
    $radio_groupbox.Location = '5,245'
    $radio_groupbox.Size = '170,90'
    $radio_groupbox.BorderStyle = 'FixedSingle'
    

        #--------------------------------------------------------------------
        #                            RADIO BUTTONS
        #--------------------------------------------------------------------
        #---------------------------------------------------------------------
        # Radio button 1 multithreaded rendering
        #---------------------------------------------------------------------
        $radiobutton_m = New-Object System.Windows.Forms.RadioButton
        $radiobutton_m.Location = '15,5'
        $radiobutton_m.Size = '150,25'
        $radiobutton_m.Text = "Multithreaded rendering"
        $radiobutton_m.Checked = $true
        $radiobutton_m.ForeColor = $fore_color
        $radiobutton_m.AutoSize = $true
        $radiobutton_m.FlatStyle = 'Flat'
        
        #---------------------------------------------------------------------
        # Radio button 2 consecutive rendering
        #---------------------------------------------------------------------
        $radiobutton_c = New-Object System.Windows.Forms.RadioButton
        $radiobutton_c.Location = '15,30'
        $radiobutton_c.Size = '150,25'
        $radiobutton_c.Text = "Consecutive rendering"
        $radiobutton_c.ForeColor = $fore_color
        $radiobutton_c.AutoSize = $true
        $radiobutton_c.FlatStyle = 'Flat'
        
        #---------------------------------------------------------------------
        # Radio button 3 sequential rendering
        #---------------------------------------------------------------------
        $radiobutton_s = New-Object System.Windows.Forms.RadioButton
        $radiobutton_s.Location = '15,55'
        $radiobutton_s.Size = '150,25'
        $radiobutton_s.Text = "Sequential rendering"
        $radiobutton_s.ForeColor = $fore_color
        $radiobutton_s.AutoSize = $true
        $radiobutton_s.FlatStyle = 'Flat'
              
    $radio_groupbox.Controls.AddRange(@(
    
        $radiobutton_m,
        $radiobutton_c,
        $radiobutton_s
    ))    
#---------------------------------------------------------------------
# LOG GROUPBOX
#---------------------------------------------------------------------  
    $log_groupbox = New-Object System.Windows.Forms.Panel
    $log_groupbox.Location = '180,245'
    $log_groupbox.Size = '365,90'
    $log_groupbox.BorderStyle = 'FixedSingle'
        
        #--------------------------------------------------------------------
        #                            LABELS
        #--------------------------------------------------------------------
        #-------------------------------------------------------------------- 
        # Label 8 Log to file
        #-------------------------------------------------------------------- 
        $log_file_label = New-Object System.Windows.Forms.Label
        $log_file_label.Text = 'Log to file'
        $log_file_label.Size = '80,20'
        $log_file_label.Location = '5,5'
        $log_file_label.ForeColor = $fore_color
        $log_file_label.BorderStyle = 'None'
        $log_file_label.TextAlign = 'BottomLeft'
        $log_file_label.AutoSize = $true

        #-------------------------------------------------------------------- 
        # Label 9 Log name textbox
        #-------------------------------------------------------------------- 
        $log_name_label = New-Object System.Windows.Forms.Label
        $log_name_label.Text = 'Log file name:'
        $log_name_label.Size = '80,20'
        $log_name_label.Location = '5,32'
        $log_name_label.ForeColor = $fore_color
        $log_name_label.BorderStyle = 'None'
        $log_name_label.TextAlign = 'BottomLeft'
        $log_name_label.AutoSize = $true
        
        #-------------------------------------------------------------------- 
        # Label 10 Log verbosity
        #-------------------------------------------------------------------- 
        $log_verbosity_label = New-Object System.Windows.Forms.Label
        $log_verbosity_label.Text = 'Verbosity:'
        $log_verbosity_label.Size = '70,20'
        $log_verbosity_label.Location = '5,60'
        $log_verbosity_label.ForeColor = $fore_color
        $log_verbosity_label.BorderStyle = 'None'
        $log_verbosity_label.TextAlign = 'BottomLeft'
        $log_verbosity_label.AutoSize = $true
        
        #---------------------------------------------------------------------
        # Checkbox 1 Log to file
        #---------------------------------------------------------------------
        $log_file_checkbox = New-Object System.Windows.Forms.CheckBox
        $log_file_checkbox.Size = '15,15'
        $log_file_checkbox.Location = '90,10'
        
        
        #---------------------------------------------------------------------
        # Dropdown verbosity
        #---------------------------------------------------------------------
        $log_verbosity_level = "Errors", "Warnings", "Info", "Debug"
        $log_verbosity_dropdown = New-Object System.Windows.Forms.ComboBox             
        $log_verbosity_dropdown.DropDownStyle = 'DropDownList'
        $log_verbosity_dropdown.Location = '90,60'
        $log_verbosity_dropdown.Size = '60,25'
        $log_verbosity_dropdown.Items.AddRange(@($log_verbosity_level))
        $log_verbosity_dropdown.SelectedItem = $log_verbosity_level[0]
        $log_verbosity_dropdown.FlatStyle = 'Flat'
        $log_verbosity_dropdown.ForeColor = $fore_color
        $log_verbosity_dropdown.BackColor = $back_color
        
        #---------------------------------------------------------------------
        # Textbox file name
        #---------------------------------------------------------------------
        $log_filename_textbox = New-Object System.Windows.Forms.TextBox
        $log_filename_textbox.Size = '60,10'
        $log_filename_textbox.Location = '90,30'
        $log_filename_textbox.BorderStyle = 'FixedSingle'
        $log_filename_textbox.ForeColor = $fore_color
        $log_filename_textbox.BackColor = $back_color
        
        
       
         
            $log_groupbox.Controls.AddRange(@(
            
            
            $log_file_label,
            $log_name_label,
            $log_verbosity_label,
            $log_file_checkbox,
            $log_verbosity_dropdown,
            $log_filename_textbox
        ))     
#---------------------------------------------------------------------
# START/STOP GROUPBOX
#---------------------------------------------------------------------
    $ss_groupbox = New-Object System.Windows.Forms.Panel
    $ss_groupbox.Location = '5,340'
    $ss_groupbox.size = '540,55'
    $ss_groupbox.BorderStyle = 'FixedSingle'

        #---------------------------------------------------------------------
        #                             BUTTONS
        #---------------------------------------------------------------------    
        #---------------------------------------------------------------------   
        # Button 3 Start process
        #--------------------------------------------------------------------
        $start_button = New-Object System.Windows.Forms.Button
        $start_button.Text = "START"
        $start_button.Size = '50,33'
        $start_button.Location = '200,10'
        $start_button.visible = $true
        $start_button.ForeColor = $fore_color
    
        #---------------------------------------------------------------------   
        # Button 4 Stop process
        #--------------------------------------------------------------------
        $stop_button = New-Object System.Windows.Forms.Button
        $stop_button.Text = "STOP"
        $stop_button.Size = '50,33'
        $stop_button.Location = '270,10'
        $stop_button.visible = $true
        $stop_button.ForeColor = $fore_color

        $ss_groupbox.Controls.AddRange(@(
    
            $start_button,
            $stop_button
        ))
         
#--------------------------------------------------------------------
# Add components to form 
#--------------------------------------------------------------------

$render_form.Controls.AddRange(@(
    
    $input_groupbox,
    $processor_groupbox,
    $radio_groupbox,
    $ss_groupbox,     
    $log_groupbox
        
    ))

#---------------------------------------------------------------------------------GUI END-----------------------------------------------------------------------------------------
#--------------------------------------------------------------------
#                        RENDER START 
#--------------------------------------------------------------------

$start_button.Add_Click({

 
    $ai_threads = $thread_dropdown.SelectedItem
    $output_dir = $folderBrowser.SelectedPath
    $file_path = $OpenFileDialog.FileName
    $cam_name = $textbox_camera.Text
    $start_frame = $textbox_startframe.Text
    $start_frame_mul = $start_frame..$ai_threads
    $end_frame = $textbox_endframe.Text
    $sequence = $textbox_seq.Text
    
    $log_filename = $log_filename_textbox.Text
    $log_to_file = 1
    $log_verbosity = $log_verbosity_dropdown.SelectedIndex

       
If ($log_file_checkbox.Checked){$switch_log = "-ai:ltf $log_to_file -ai:lfn '$log_filename' -ai:lve $log_verbosity"} 
  
    $mul = ForEach ($i in $start_frame_mul) {
      "Render -r arnold -rd $output_dir -s $i -b $ai_threads -e $end_frame $switch_log -cam $cam_name $file_path"
    }
    $con = "Render -r arnold -rd $output_dir -s $start_frame -e $end_frame $switch_log -cam $cam_name $file_path"                      
    $seq = "Render -r arnold -rd $output_dir -seq '$sequence' $switch_log -cam $cam_name $file_path"
    $gpu = "Render -r arnold -rd $output_dir -ai:device 1 -s $start_frame -e $end_frame $switch_log -cam $cam_name $file_path"   


If ($select_device.SelectedItem -eq "$CPU" -and $radiobutton_m.Checked -eq $true){
    Render-Job($mul)
    }
ElseIf($select_device.SelectedItem -eq "$CPU" -and $radiobutton_c.Checked -eq $true){
    Render-Job($con)
    }
ElseIf($select_device.SelectedItem -eq "$CPU" -and $radiobutton_s.Checked -eq $true){
    Render-Job($seq)
    }
Else{
    Render-Job($gpu)
    }

 $start_button.Enabled = $false
 
})

$stop_button.add_click({

    Stop-Process -Name mayabatch -ErrorAction SilentlyContinue
    Remove-Variable * -ErrorAction SilentlyContinue
    $start_button.Enabled = $true
})




[void]$render_form.ShowDialog() 