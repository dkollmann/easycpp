tool
extends WindowDialog
class_name SettingsWindow


func load_settings():
	var locbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/LocationButton
	locbutton.items = Constants.setting_batchfilelocation_items
	locbutton.selected = ProjectSettings.get(Constants.setting_batchfilelocation)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/BuildFolderEdit.filepath = ProjectSettings.get(Constants.setting_buildfolder)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/OverwriteCheckBox.pressed = ProjectSettings.get(Constants.setting_overwritemakefiles)
	
	var vslocbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/LocationButton
	vslocbutton.items = Constants.setting_vsproj_location_items
	vslocbutton.selected = ProjectSettings.get(Constants.setting_vsproj_location)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/SubfolderLineEdit.text = ProjectSettings.get(Constants.setting_vsproj_subfolder)
	
	var platforms := BuildFactory.new().parse_csv_pltfrm( ProjectSettings.get(Constants.setting_buildplatforms), true )
	var configurations := BuildFactory.new().parse_csv_cfg( ProjectSettings.get(Constants.setting_buildconfigurations), true )


func _on_AllSettingsButton_pressed():
	hide()
	
	# show project settings
