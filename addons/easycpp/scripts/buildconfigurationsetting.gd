tool
extends Tabs


func setobj(bld :BuildConfiguration) -> void:
	name = bld.name
	
	$PropertiesContainer/NameLineEdit.text = bld.name
	$PropertiesContainer/EnabledCheckBox.pressed = bld.enabled
	$PropertiesContainer/ArgumentsEdit.text = PoolStringArray(bld.arguments).join("\n")
	$PropertiesContainer/DefinesEdit.text = PoolStringArray(bld.defines).join("\n")
	$PropertiesContainer/DebugLibCheckbox.pressed = bld.debuglibs


func createobj() -> BuildConfiguration:
	var bld := BuildConfiguration.new()
	
	bld.name = $PropertiesContainer/NameLineEdit.text.strip_edges()
	bld.enabled = $PropertiesContainer/EnabledCheckBox.pressed
	bld.arguments = Utils.split_clean($PropertiesContainer/ArgumentsEdit.text, "\n", false)
	bld.defines = Utils.split_clean($PropertiesContainer/DefinesEdit.text, "\n", false)
	bld.debuglibs = $PropertiesContainer/DebugLibCheckbox.pressed
	
	return bld


func createnewobj() -> BuildConfiguration:
	var bld := BuildConfiguration.new()
	
	bld.name = "Untitled"
	bld.enabled = true
	bld.arguments = []
	bld.defines = []
	
	return bld


func _on_NameLineEdit_text_changed(new_text):
	name = new_text
