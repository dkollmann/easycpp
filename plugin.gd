tool
extends EditorPlugin

var toolwindow :Control


func _enter_tree():
	toolwindow = preload("res://addons/easycpp/scenes/tool_window.tscn").instance()
	
	toolwindow.editorbase = get_editor_interface().get_base_control()
	
	add_control_to_dock(DOCK_SLOT_LEFT_UL, toolwindow)


func _exit_tree():
	remove_control_from_docks(toolwindow)
	
	toolwindow.free()
