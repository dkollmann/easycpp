tool
extends Tabs


func setobj(bld :BuildPlatform) -> void:
	name = bld.name
	
	$PropertiesContainer/NameLineEdit.text = bld.name
	$PropertiesContainer/EnabledCheckBox.pressed = bld.enabled
	$PropertiesContainer/AvailableOnContainer/WindowsCheckBox.pressed = "Windows" in bld.availableon
	$PropertiesContainer/AvailableOnContainer/LinuxCheckBox.pressed = "X11" in bld.availableon
	$PropertiesContainer/AvailableOnContainer/MacOSCheckBox.pressed = "OSX" in bld.availableon
	$PropertiesContainer/ArgumentsEdit.text = PoolStringArray(bld.arguments).join("\n")
	$PropertiesContainer/DefinesEdit.text = PoolStringArray(bld.defines).join("\n")
	$PropertiesContainer/OutputLineEdit.text = bld.outputname
	$PropertiesContainer/GDNLIBLineEdit.text = bld.gdnlibkey
	$PropertiesContainer/VSToolchainLineEdit.text = bld.vsplatform

func createobj() -> BuildPlatform:
	var bld := BuildPlatform.new()
	
	var availableon := []
	
	if $PropertiesContainer/AvailableOnContainer/WindowsCheckBox.pressed:
		availableon.append("Windows")
	if $PropertiesContainer/AvailableOnContainer/LinuxCheckBox.pressed:
		availableon.append("X11")
	if $PropertiesContainer/AvailableOnContainer/MacOSCheckBox.pressed:
		availableon.append("OSX")
	
	bld.name = $PropertiesContainer/NameLineEdit.text.strip_edges()
	bld.enabled = $PropertiesContainer/EnabledCheckBox.pressed
	bld.availableon = PoolStringArray(availableon).join(" ")
	bld.arguments = Utils.split_clean($PropertiesContainer/ArgumentsEdit.text, "\n", false)
	bld.defines = Utils.split_clean($PropertiesContainer/DefinesEdit.text, "\n", false)
	bld.outputname = $PropertiesContainer/OutputLineEdit.text.strip_edges()
	bld.gdnlibkey = $PropertiesContainer/GDNLIBLineEdit.text.strip_edges()
	bld.vsplatform = $PropertiesContainer/VSToolchainLineEdit.text.strip_edges()
	
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
