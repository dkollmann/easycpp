tool
extends EditorPlugin

const utils := preload("res://addons/easycpp/scripts/utils.gd")
const tempres := "res://addons/easycpp/temp"
const setting_pythonpath := "Editor/Easy C++/Python Path"

var temppath :String
var pythonpath :String
var pythonpath_windowsstore :String

var has_python := false

var toolwindow :Control


func _enter_tree():
	temppath = ProjectSettings.globalize_path(tempres)
	
	print("Easy C++ temporary folder: \"" + temppath + "\".")
	
	Directory.new().make_dir(tempres)
	
	toolwindow = preload("res://addons/easycpp/scenes/tool_window.tscn").instance()
	
	add_control_to_dock(DOCK_SLOT_LEFT_UL, toolwindow)
	
	self.check_sdk_state()


func _exit_tree():
	remove_control_from_docks(toolwindow)
	
	toolwindow.free()


func check_sdk_state():
	var searchedpython := false
	
	pythonpath = utils.get_project_setting(setting_pythonpath, TYPE_STRING, "", PROPERTY_HINT_DIR)
	
	if pythonpath.empty():
		searchedpython = true
		find_python()
	
	has_python = not pythonpath.empty() and utils.file_exists(pythonpath)
	
	if has_python:
		print("Found Python path: \"" + pythonpath + "\".")
		
		if searchedpython:
			ProjectSettings.set(setting_pythonpath, pythonpath)


func find_python() -> void:
	var output = []
	OS.execute("where" if utils.is_windows() else "which", ["python"], true, output)
	
	if len(output) > 0:
		var exe = output[0].strip_edges()
		
		if utils.file_exists(exe):
			pythonpath = exe
		else:
			if utils.is_windows():
				# Under Windows 10, this opens the store
				pythonpath_windowsstore = exe
				
func install_python():
	if utils.is_windows():
		if not pythonpath_windowsstore.empty():
			# Under Windows 10, this opens the store
			OS.execute(pythonpath_windowsstore, [])
