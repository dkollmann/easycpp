tool
extends BuildSetting


func setobj(bld :BuildPlatform) -> void:
	name = bld.name
	
	$ScrollContainer/PropertiesContainer/NameLineEdit.text = bld.name
	$ScrollContainer/PropertiesContainer/EnabledCheckBox.pressed = bld.enabled
	$ScrollContainer/PropertiesContainer/AvailableOnContainer/WindowsCheckBox.pressed = "Windows" in bld.availableon
	$ScrollContainer/PropertiesContainer/AvailableOnContainer/LinuxCheckBox.pressed = "X11" in bld.availableon
	$ScrollContainer/PropertiesContainer/AvailableOnContainer/MacOSCheckBox.pressed = "OSX" in bld.availableon
	$ScrollContainer/PropertiesContainer/ArgumentsEdit.text = PoolStringArray(bld.arguments).join("\n")
	$ScrollContainer/PropertiesContainer/DefinesEdit.text = PoolStringArray(bld.defines).join("\n")
	$ScrollContainer/PropertiesContainer/OutputLineEdit.text = bld.outputname
	$ScrollContainer/PropertiesContainer/GDNLIBLineEdit.text = bld.gdnlibkey
	$ScrollContainer/PropertiesContainer/VSToolchainLineEdit.text = bld.vsplatform

func createobj() -> BuildPlatform:
	var bld := BuildPlatform.new()
	
	var availableon := []
	
	if $ScrollContainer/PropertiesContainer/AvailableOnContainer/WindowsCheckBox.pressed:
		availableon.append("Windows")
	if $ScrollContainer/PropertiesContainer/AvailableOnContainer/LinuxCheckBox.pressed:
		availableon.append("X11")
	if $ScrollContainer/PropertiesContainer/AvailableOnContainer/MacOSCheckBox.pressed:
		availableon.append("OSX")
	
	bld.name = $ScrollContainer/PropertiesContainer/NameLineEdit.text.strip_edges()
	bld.enabled = $ScrollContainer/PropertiesContainer/EnabledCheckBox.pressed
	bld.availableon = PoolStringArray(availableon).join(" ")
	bld.arguments = Utils.split_clean($ScrollContainer/PropertiesContainer/ArgumentsEdit.text, "\n", false)
	bld.defines = Utils.split_clean($ScrollContainer/PropertiesContainer/DefinesEdit.text, "\n", false)
	bld.outputname = $ScrollContainer/PropertiesContainer/OutputLineEdit.text.strip_edges()
	bld.gdnlibkey = $ScrollContainer/PropertiesContainer/GDNLIBLineEdit.text.strip_edges()
	bld.vsplatform = $ScrollContainer/PropertiesContainer/VSToolchainLineEdit.text.strip_edges()
	
	return bld


func createnewobj() -> BuildPlatform:
	var bld := BuildPlatform.new()
	
	bld.name = "Untitled"
	bld.enabled = true
	bld.availableon = "Windows X11 OSX"
	bld.arguments = []
	bld.defines = []
	bld.outputname = "lib%name%.%platform%.%target%.%bits%.xxx"
	
	return bld


func _on_NameLineEdit_text_changed(new_text):
	name = new_text
