tool
extends WindowDialog
class_name SettingsWindow


static func set_optionbutton_items(btn :OptionButton, items :Array) -> void:
	for i in range(len(items)):
		btn.add_item(items[i], i)


func load_settings(utils :Utils):
	var locbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/LocationButton
	set_optionbutton_items(locbutton, Constants.setting_batchfilelocation_items)
	locbutton.selected = ProjectSettings.get(Constants.setting_batchfilelocation)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/BuildFolderEdit.filepath = ProjectSettings.get(Constants.setting_buildfolder)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/OverwriteCheckBox.pressed = ProjectSettings.get(Constants.setting_overwritemakefiles)
	
	if utils.system == Utils.System.Windows:
		var vslocbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/LocationButton
		set_optionbutton_items(vslocbutton, Constants.setting_vsproj_location_items)
		vslocbutton.selected = ProjectSettings.get(Constants.setting_vsproj_location)
		
		$SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/SubfolderLineEdit.text = ProjectSettings.get(Constants.setting_vsproj_subfolder)
	else:
		$SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer.visible = false

	var platforms := BuildFactory.new().parse_csv_pltfrm( ProjectSettings.get(Constants.setting_buildplatforms), true )
	var configurations := BuildFactory.new().parse_csv_cfg( ProjectSettings.get(Constants.setting_buildconfigurations), true )
	
	$SettingsContainer/TabContainer/BuildPlatforms/VBoxContainer/TabControl.generate_tabs(platforms)


func _on_AllSettingsButton_pressed():
	hide()
	
	# show project settings
