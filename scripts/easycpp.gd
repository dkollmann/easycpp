tool
extends VBoxContainer

enum BuildSystem {
	Scons,
	Cmake
}

const utils := preload("res://addons/easycpp/scripts/utils.gd")
const toolsres := "res://addons/easycpp/tools"
const tempres := "res://addons/easycpp/temp"
const setting_buildsystem := "Easy C++/Build System"
const setting_pythonpath := "Easy C++/Python Path"
const setting_gitpath := "Easy C++/Git Path"
const setting_gdcpppath := "Easy C++/Godot-CPP Path"
const status_good := preload("res://addons/easycpp/resources/textures/status_good.png")
const status_error := preload("res://addons/easycpp/resources/textures/status_error.png")
const gdcpppath_testfile := "/include/core/Godot.hpp"
const gdheaderspath_testfile := "/nativescript/godot_nativescript.h"
const gdcppgiturl = "https://github.com/godotengine/godot-cpp.git"
const gdcppgitbranch = "nativescript-1.1"

var toolspath :String
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

var needs_python := true
var needs_git := true

var allgood := false

var buildsystem :int = BuildSystem.Scons


func _ready():
	temppath = ProjectSettings.globalize_path(tempres)
	toolspath = ProjectSettings.globalize_path(toolsres)
	
	print("Easy C++ temporary folder: \"" + temppath + "\".")
	
	#utils.make_dir(temppath)
	
	init_optionbutton($BuildSystemButton, setting_buildsystem, BuildSystem)
	
	add_tooltip($BuildSystemButton, "Select which build system will be used to build your code.")
	add_tooltip($MenuContainer/RefreshButton, "Check again if all required components are installed.")
	
	var atfunc := funcref(self, "add_tooltip")
	$StatusContainer/PythonStatus.add_tooltip(atfunc, "Python is required to run Scons.")
	$StatusContainer/GitStatus.add_tooltip(atfunc, "Git is required to check out the godot-cpp files and headers. You can also download them yourself.")
	$StatusContainer/CppStatus.add_tooltip(atfunc, "The godot-cpp files are required to build your code.")
	$StatusContainer/HeaderStatus.add_tooltip(atfunc, "The godot header files are required to build your code and must bne placed inside the godot-cpp folder.")
	
	check_sdk_state()


func init_optionbutton(button :OptionButton, setting :String, enumtype, defvalue :int = 0) -> void:
	button.clear()
	
	for k in enumtype.keys():
		button.add_item(k)
	
	button.select( utils.get_project_setting_enum(setting, enumtype, defvalue) )


func add_tooltip(ctrl :Control, tooltip :String) -> void:
	ctrl.connect("mouse_entered", self, "_on_tooltip_show", [tooltip])
	ctrl.connect("mouse_exited", self, "_on_tooltip_hide")
	
	if ctrl.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		ctrl.mouse_filter = Control.MOUSE_FILTER_STOP


func status_res(good :bool) -> Texture:
	return status_good if good else status_error


func check_sdk_state() -> void:
	var exefilter := "*.exe,*.bat,*.cmd" if utils.is_windows() else "*"
	
	# prepare check
	needs_python = buildsystem == BuildSystem.Scons
	
	# handle python
	if needs_python:
		pythonpath = check_installation("Python", funcref(self, "find_python"), setting_pythonpath, false, exefilter)
		has_python = utils.file_exists(pythonpath)
	
	# handle git
	gitpath = check_installation("Git", funcref(self, "find_git"), setting_gitpath, false, exefilter)
	has_git = utils.file_exists(gitpath)
	
	# handle godot-cpp
	gdcpppath = check_installation("godot-cpp", funcref(self, "find_godotcpp"), setting_gdcpppath, true)
	has_gdcpp = utils.file_exists(gdcpppath + gdcpppath_testfile)
	
	# handle godot-cpp
	gdheaderspath = gdcpppath + "/godot_headers"
	has_gdheaders = utils.file_exists(gdheaderspath + gdheaderspath_testfile)
	
	needs_git = not has_gdcpp  # or not has_gdheaders
	
	var wants_python := needs_python and not has_python
	var wants_git := needs_git and not has_git
	
	allgood = not wants_python and not wants_git and has_gdcpp and has_gdcpp and has_gdheaders
	
	if allgood:
		$StatusContainer.visible = false
	
	else:
		var canfix_python := not utils.is_windows()  # or not pythonpath_windowsstore.empty()
		var canfix_git := not utils.is_windows()
		
		$StatusContainer/PythonStatus.visible = needs_python
		$StatusContainer/GitStatus.visible = needs_git
		$FixIssuesContainer/FixButton1.visible = false
		$FixIssuesContainer/FixButton2.visible = false
		
		$StatusContainer/PythonStatus.set_status(has_python, true, canfix_python)
		$StatusContainer/GitStatus.set_status(has_git, true, canfix_git)
		$StatusContainer/CppStatus.set_status(has_gdcpp, true, has_git)
		$StatusContainer/HeaderStatus.set_status(has_gdheaders, true, false)
		
		$StatusContainer.visible = true


func set_fixbutton(text :String, fixfunc :String) -> void:
	var btn := $FixIssuesContainer/FixButton1
	
	if btn.visible:
		btn = $FixIssuesContainer/FixButton2
	
	if btn.visible:
		return
	
	btn.connect("pressed", self, fixfunc)


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


func git_clone(args :Array, tryfix :bool = true) -> bool:
	if not has_git:
		return false
		
	var output := []
	var good := OS.execute(gitpath, args, true, output, true) == 0
	
	print(output)
	
	if good:
		return true
	
	# try invalid branch name hotfix
	if tryfix and len(output) > 0 and "fatal: invalid branch name: init.defaultBranch" in output[0]:
		print("Trying to hotfix invalid default branch name issue...")
		
		OS.execute(gitpath, ["config", "--global", "init.defaultBranch", "master"], true, output, true)
	
		print(output)
		
		return git_clone(args, false)
		
	return false


func _on_tooltip_show(text :String) -> void:
	$TooltipPanel/TooltipLabel.text = text


func _on_tooltip_hide() -> void:
	$TooltipPanel/TooltipLabel.text = ""


func _on_RefreshButton_pressed():
	check_sdk_state()


func _on_BuildSystemButton_item_selected(index):
	print("Selected build system: " + BuildSystem.keys()[index])
	
	buildsystem = index
	
	check_sdk_state()


func _on_PythonStatus_fix_pressed():
	if utils.is_windows():
		OS.execute(pythonpath_windowsstore, [])
	else:
		# TODO: Support linux
		pass


func _on_PythonStatus_www_pressed():
	OS.shell_open("https://www.python.org/downloads/")


func _on_GitStatus_fix_pressed():
	# TODO: Support linux
	pass


func _on_GitStatus_www_pressed():
	OS.shell_open("https://git-scm.com/downloads")


func _on_CppStatus_fix_pressed():
	if has_git:
		git_clone(["clone", "--recurse-submodules", "--branch", gdcppgitbranch, gdcppgiturl, gdcpppath])
		
	check_sdk_state()


func _on_CppStatus_www_pressed():
	OS.shell_open("https://github.com/godotengine/godot-cpp")


func _on_HeaderStatus_www_pressed():
	OS.shell_open("https://github.com/godotengine/godot-headers")
