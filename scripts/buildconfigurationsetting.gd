tool
extends BuildSetting


func setobj(bld :BuildConfiguration) -> void:
	name = bld.name
	
	$ScrollContainer/PropertiesContainer/NameLineEdit.text = bld.name
	$ScrollContainer/PropertiesContainer/EnabledCheckBox.pressed = bld.enabled
	$ScrollContainer/PropertiesContainer/ArgumentsEdit.text = PoolStringArray(bld.arguments).join("\n")
	$ScrollContainer/PropertiesContainer/DefinesEdit.text = PoolStringArray(bld.defines).join("\n")
	$ScrollContainer/PropertiesContainer/DebugLibCheckbox.pressed = bld.debuglibs


func createobj() -> BuildConfiguration:
	var bld := BuildConfiguration.new()
	
	bld.name = $ScrollContainer/PropertiesContainer/NameLineEdit.text.strip_edges()
	bld.enabled = $ScrollContainer/PropertiesContainer/EnabledCheckBox.pressed
	bld.arguments = Utils.split_clean($ScrollContainer/PropertiesContainer/ArgumentsEdit.text, "\n", false)
	bld.defines = Utils.split_clean($ScrollContainer/PropertiesContainer/DefinesEdit.text, "\n", false)
	bld.debuglibs = $ScrollContainer/PropertiesContainer/DebugLibCheckbox.pressed
	
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
