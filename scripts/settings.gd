@tool
extends Window
class_name SettingsWindow


var utils :ECPP_Utils
var save :bool


static func set_optionbutton_items(btn :OptionButton, items :Array) -> void:
	for i in range(len(items)):
		btn.add_item(items[i], i)


func load_settings(utls :ECPP_Utils):
	utils = utls
	save = false
	
	var locbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/LocationButton
	set_optionbutton_items(locbutton, Constants.setting_batchfilelocation_items)
	locbutton.selected = ProjectSettings.get(Constants.setting_batchfilelocation)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/BuildFolderEdit.filepath = ProjectSettings.get(Constants.setting_buildfolder)
	
	$SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/OverwriteCheckBox.button_pressed = ProjectSettings.get(Constants.setting_overwritemakefiles)
	
	if utils.system == ECPP_Utils.System.Windows:
		var vslocbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/LocationButton
		set_optionbutton_items(vslocbutton, Constants.setting_vsproj_location_items)
		vslocbutton.selected = ProjectSettings.get(Constants.setting_vsproj_location)
		
		$SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/SubfolderLineEdit.text = ProjectSettings.get(Constants.setting_vsproj_subfolder)
	else:
		$SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer.visible = false
	
	var bldfac := BuildFactory.new()
	
	var platforms := bldfac.parse_csv_pltfrm( ProjectSettings.get(Constants.setting_buildplatforms), true )
	var configurations := bldfac.parse_csv_cfg( ProjectSettings.get(Constants.setting_buildconfigurations), true )
	
	$"SettingsContainer/TabContainer/Build Platforms/TabControl".generate_tabs(platforms)
	$"SettingsContainer/TabContainer/Build Configurations/TabControl".generate_tabs(configurations)


func save_settings():
	var locbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/LocationButton
	
	ProjectSettings.set(Constants.setting_batchfilelocation, locbutton.selected)

	ProjectSettings.set(Constants.setting_buildfolder, $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/BuildFolderEdit.filepath.strip_edges())
	
	ProjectSettings.set(Constants.setting_overwritemakefiles, $SettingsContainer/TabContainer/Settings/VBoxContainer/BatchfilesContainer/VBoxContainer/GridContainer/OverwriteCheckBox.pressed)
	
	if utils.system == ECPP_Utils.System.Windows:
		var vslocbutton := $SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/LocationButton
		
		ProjectSettings.set(Constants.setting_vsproj_location, vslocbutton.selected)
		
		ProjectSettings.set(Constants.setting_vsproj_subfolder, $SettingsContainer/TabContainer/Settings/VBoxContainer/VSContainer/VBoxContainer/GridContainer/SubfolderLineEdit.text.strip_edges())
	
	# save build platforms
	var platforms = $"SettingsContainer/TabContainer/Build Platforms/TabControl".generate_objects()
	
	var platforms_str := []
	var bldfac := BuildFactory.new()
	
	for bld in platforms:
		platforms_str.append( bldfac.makestr_pltfrm(bld) )
	
	var newplatforms := "\n".join(platforms_str)
	
	#print(newplatforms)
	
	# save build platforms
	var configurations = $"SettingsContainer/TabContainer/Build Configurations/TabControl".generate_objects()
	
	var configurations_str := []
	
	for bld in configurations:
		configurations_str.append( bldfac.makestr_cfg(bld) )
	
	var newconfigurations := "\n".join(configurations_str)
	
	#print(newplatforms)
	
	# set the actual values
	ProjectSettings.set(Constants.setting_buildplatforms, newplatforms)
	ProjectSettings.set(Constants.setting_buildconfigurations, newconfigurations)


func _on_AllSettingsButton_pressed():
	hide()
	
	# show project settings


func _on_SaveButton_pressed():
	save = true
	save_settings()
	hide()


func _on_CancelButton_pressed():
	hide()
