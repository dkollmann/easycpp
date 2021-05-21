tool
extends VBoxContainer

const utils := preload("res://addons/easycpp/scripts/utils.gd")
const tempres := "res://addons/easycpp/temp"
const setting_pythonpath := "Easy C++/Python Path"
const setting_gitpath := "Easy C++/Git Path"
const setting_gdcpppath := "Easy C++/Godot-CPP Path"
const status_good := preload("res://addons/easycpp/resources/textures/status_good.png")
const status_error := preload("res://addons/easycpp/resources/textures/status_error.png")
const gdcpppath_testfile := "include/core/Godot.hpp"
const gdheaderspath_testfile := "nativescript/godot_nativescript.h"

var temppath :String
var gdcpppath :String
var gdheaderspath :String
var pythonpath :String
var pythonpath_windowsstore :String
var gitpath :String

var has_python := false
var has_git := false
var has_gdcpp := false
var has_gdheaders := false
var allgood := false


func _ready():
	temppath = ProjectSettings.globalize_path(tempres)
	
	print("Easy C++ temporary folder: \"" + temppath + "\".")
	
	#utils.make_dir(temppath)
	
	check_sdk_state()


func status_res(good :bool) -> Texture:
	return status_good if good else status_error


func check_sdk_state() -> void:
	var exefilter := "*.exe,*.bat,*.cmd" if utils.is_windows() else "*"
	
	# handle python
	pythonpath = check_installation("Python", funcref(self, "find_python"), setting_pythonpath, false, exefilter)
	has_python = utils.file_exists(pythonpath)
	
	# handle git
	gitpath = check_installation("Git", funcref(self, "find_git"), setting_gitpath, false, exefilter)
	has_git = utils.file_exists(gitpath)
	
	# handle godot-cpp
	gdcpppath = check_installation("Godot CPP", funcref(self, "find_godotcpp"), setting_gdcpppath, true)
	has_gdcpp = utils.file_exists(gdcpppath + gdcpppath_testfile)
	
	# handle godot-cpp
	gdheaderspath = gdcpppath + "/godot_headers"
	has_gdheaders = utils.file_exists(gdheaderspath + gdheaderspath_testfile)
	
	allgood = has_python and has_git and has_gdcpp and has_gdcpp and has_gdheaders
	
	$SetupStatus/PythonStatus.texture = status_res(has_python)
	$SetupStatus/GitStatus.texture = status_res(has_git)
	$SetupStatus/CppStatus.texture = status_res(has_gdcpp)
	$SetupStatus/HeadersStatus.texture = status_res(has_gdheaders)


static func check_installation(name :String, findfunc :FuncRef, setting_name :String, isfolder :bool, filter :String = "") -> String:
	var searched := false
	
	var path = utils.get_project_setting(setting_name, TYPE_STRING, "", PROPERTY_HINT_DIR if isfolder else PROPERTY_HINT_FILE, filter)
	
	if path.empty():
		searched = true
		path = findfunc.call_func()
	
	if (utils.folder_exists(path) if isfolder else utils.file_exists(path)):
		print("Found " + name + " path: \"" + path + "\".")
		
		if searched:
			ProjectSettings.set(setting_name, path)
			
	else:
		print("Could not find any version of " + name + "!")
	
	return path


static func find_executable(exename :String) -> String:
	var output = []
	OS.execute("where" if utils.is_windows() else "which", [exename], true, output)
	
	if len(output) > 0:
		# the output is a single multi-line entry, so split it by line again
		output = output[0].split("\n", false)
		
		return output[0].strip_edges()
		
	return ""


func find_python() -> String:
	var exe := find_executable("python")
	
	if not exe.empty():
		if utils.file_exists(exe):
			return exe
			
		if utils.is_windows():
			# Under Windows 10, this opens the store
			pythonpath_windowsstore = exe
	
	return ""


func install_python() -> void:
	if utils.is_windows():
		if not pythonpath_windowsstore.empty():
			# Under Windows 10, this opens the store
			OS.execute(pythonpath_windowsstore, [])
	else:
		# TODO: Install python package
		pass


func find_git() -> String:
	return find_executable("git")


func find_godotcpp() -> String:
	return temppath + "/godot-cpp"
