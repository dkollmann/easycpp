tool
extends Tabs


func setobj(bld :BuildConfiguration) -> void:
	name = bld.name
	
	$VBoxContainer/NameContainer/NameLineEdit.text = bld.name
	$VBoxContainer/NameContainer/EnabledCheckBox.pressed = bld.enabled
	$VBoxContainer/PropertiesContainer/ArgumentsEdit.text = PoolStringArray(bld.arguments).join("\n")
	$VBoxContainer/PropertiesContainer/DefinesEdit.text = PoolStringArray(bld.defines).join("\n")
	$VBoxContainer/PropertiesContainer/DebugLibCheckbox.pressed = bld.debuglibs


func createobj() -> BuildConfiguration:
	var bld := BuildConfiguration.new()
	
	bld.name = $VBoxContainer/NameContainer/NameLineEdit.text.strip_edges()
	bld.enabled = $VBoxContainer/NameContainer/EnabledCheckBox.pressed
	bld.arguments = Utils.split_clean($VBoxContainer/PropertiesContainer/ArgumentsEdit.text, "\n", false)
	bld.defines = Utils.split_clean($VBoxContainer/PropertiesContainer/DefinesEdit.text, "\n", false)
	bld.debuglibs = $VBoxContainer/PropertiesContainer/DebugLibCheckbox.pressed
	
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
