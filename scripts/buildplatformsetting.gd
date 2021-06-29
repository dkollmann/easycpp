tool
extends Tabs

func setobj(bld :BuildPlatform) -> void:
	name = bld.name
	
	$VBoxContainer/NameContainer/NameLineEdit.text = bld.name
	$VBoxContainer/NameContainer/EnabledCheckBox.pressed = bld.enabled
	$VBoxContainer/PropertiesContainer/AvailableOnContainer/WindowsCheckBox.pressed = "Windows" in bld.availableon
	$VBoxContainer/PropertiesContainer/AvailableOnContainer/LinuxCheckBox.pressed = "X11" in bld.availableon
	$VBoxContainer/PropertiesContainer/AvailableOnContainer/MacOSCheckBox.pressed = "OSX" in bld.availableon
	$VBoxContainer/PropertiesContainer/ArgumentsEdit.text = PoolStringArray(bld.arguments).join("\n")
	$VBoxContainer/PropertiesContainer/DefinesEdit.text = PoolStringArray(bld.defines).join("\n")
	$VBoxContainer/PropertiesContainer/OutputLineEdit.text = bld.outputname
	$VBoxContainer/PropertiesContainer/GDNLIBLineEdit.text = bld.gdnlibkey
	$VBoxContainer/PropertiesContainer/VSToolchainLineEdit.text = bld.vsplatform

func updateobj(bld :BuildPlatform) -> void:
	var availableon := []
	
	if $VBoxContainer/PropertiesContainer/AvailableOnContainer/WindowsCheckBox.pressed:
		availableon.append("Windows")
	if $VBoxContainer/PropertiesContainer/AvailableOnContainer/LinuxCheckBox.pressed:
		availableon.append("X11")
	if $VBoxContainer/PropertiesContainer/AvailableOnContainer/MacOSCheckBox.pressed:
		availableon.append("OSX")
	
	bld.name = $VBoxContainer/NameContainer/NameLineEdit.text.strip_edges()
	bld.enabled = $VBoxContainer/NameContainer/EnabledCheckBox.pressed
	bld.availableon = PoolStringArray(availableon).join(" ")
	bld.arguments = Utils.split_clean($VBoxContainer/PropertiesContainer/ArgumentsEdit.text, "\n", false)
	bld.defines = Utils.split_clean($VBoxContainer/PropertiesContainer/DefinesEdit.text, "\n", false)
	bld.outputname = $VBoxContainer/PropertiesContainer/OutputLineEdit.text.strip_edges()
	bld.gdnlibkey = $VBoxContainer/PropertiesContainer/GDNLIBLineEdit.text.strip_edges()
	bld.vsplatform = $VBoxContainer/PropertiesContainer/VSToolchainLineEdit.text.strip_edges()


func _on_NameLineEdit_text_changed(new_text):
	name = new_text
