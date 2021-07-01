tool
extends EditorPlugin

var toolwindow :Control


func _enter_tree():
	var path = get_script().get_path()
	
	if path != "res://addons/easycpp/plugin.gd":
		print("ERROR: The Easy C++ addon must be placed inside the folder \"res://addons/easycpp/\".")
		
		Directory.new().make_dir_recursive("res://addons/easycpp")
		
		return
	
	toolwindow = preload("res://addons/easycpp/scenes/tool_window.tscn").instance()
	
	assert(toolwindow != null)
	
	toolwindow.editorbase = get_editor_interface().get_base_control()
	
	add_control_to_dock(DOCK_SLOT_LEFT_UL, toolwindow)


func _exit_tree():
	remove_control_from_docks(toolwindow)
	
	toolwindow.free()
