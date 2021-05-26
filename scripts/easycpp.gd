tool
extends VBoxContainer

enum BuildSystem {
	SCons,
	Cmake
}

enum BuildPlatform {
	Win32,
	Win64,
	Linux,
	macOS,
	Android,
	iOS
}

enum BuildConfiguration {
	Shipping,
	Release,
	Profiling,
	Debug
}

enum Compiler {
	VisualStudio2015,
	VisualStudio2017,
	VisualStudio2019
}

enum Submenu {
	CleanBindings,
	CleanCurrentLibrary
}


const utils := preload("res://addons/easycpp/scripts/utils.gd")
const toolsres := "res://addons/easycpp/tools"
const tempres := "res://addons/easycpp/temp"
const templatesres := "res://addons/easycpp/templates"

const setting_buildsystem := "Easy C++/Build System"
const setting_pythonpath := "Easy C++/Python Path"
const setting_pippath := "Easy C++/pip Path"
const setting_sconspath := "Easy C++/SCons Path"
const setting_gitpath := "Easy C++/Git Path"
const setting_gdcpppath := "Easy C++/Godot-CPP Path"

const setting_vs2015path := "Easy C++/Compilers/Visual Studio 2015 Path"
const setting_vs2017path := "Easy C++/Compilers/Visual Studio 2017 Path"
const setting_vs2019path := "Easy C++/Compilers/Visual Studio 2019 Path"

const status_good := preload("res://addons/easycpp/resources/textures/status_good.png")
const status_error := preload("res://addons/easycpp/resources/textures/status_error.png")

const gdcpppath_testfile := "/include/core/Godot.hpp"
const gdheaderspath_testfile := "/nativescript/godot_nativescript.h"
const gdcppgiturl = "https://github.com/godotengine/godot-cpp.git"


var editorbase :Control

var vs2015path :String
var vs2017path :String
var vs2019path :String

var toolspath :String
var runinterminalpath :String
var shortpathpath :String
var temppath :String
var templatespath :String
var pythonpath :String
var pythonpath_windowsstore :String
var gitpath :String
var gdcpppath :String
var gdheaderspath :String

var has_vs2015 := false
var has_vs2017 := false
var has_vs2019 := false

var has_python := false
var has_pip := false
var has_scons := false
var has_git := false
var has_gdcpp := false
var has_gdheaders := false
var has_compiler := false

var needs_python := true
var needs_pip := true
var needs_scons := true
var needs_git := true

var allgood := false

var buildsystem :int = BuildSystem.SCons
var platform :int = -1
var buildcfg :int = BuildConfiguration.Debug
var compiler :int = -1

var gdnlibs := { }
var currentgdnlib :String

var godotversion :String
var random := RandomNumberGenerator.new()


func _ready():
	var ver := Engine.get_version_info()
	godotversion = str(ver.major) + "." + str(ver.minor)
	
	random.randomize()
	
	if utils.is_windows():
		vs2015path = utils.get_project_setting(setting_vs2015path, TYPE_STRING, "C:\\Program Files (x86)\\Microsoft Visual Studio 14.0", PROPERTY_HINT_GLOBAL_DIR)
		vs2017path = utils.get_project_setting(setting_vs2017path, TYPE_STRING, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017", PROPERTY_HINT_GLOBAL_DIR)
		vs2019path = utils.get_project_setting(setting_vs2019path, TYPE_STRING, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019", PROPERTY_HINT_GLOBAL_DIR)
		
		has_vs2015 = not find_vcvars(vs2015path).empty()
		has_vs2017 = not find_vcvars(vs2017path).empty()
		has_vs2019 = not find_vcvars(vs2019path).empty()
	
	temppath = ProjectSettings.globalize_path(tempres)
	toolspath = ProjectSettings.globalize_path(toolsres)
	templatespath = ProjectSettings.globalize_path(templatesres)
	runinterminalpath = toolspath + "/rit.exe"
	shortpathpath = toolspath + "/shortpath.bat"
	
	print("Easy C++ temporary folder: \"" + temppath + "\".")
	
	#utils.make_dir(temppath)
	
	init_optionbutton_setting($BuildSystemButton, setting_buildsystem, BuildSystem)
	init_optionbutton($PlatformContainer/ConfigurationButton, BuildConfiguration, buildcfg)
	
	$PlatformContainer/PlatformButton.clear()
	
	if utils.is_windows():
		$PlatformContainer/PlatformButton.add_item("Windows (32-bit)", BuildPlatform.Win32)
		$PlatformContainer/PlatformButton.add_item("Windows (64-bit)", BuildPlatform.Win64)
	
	platform = $PlatformContainer/PlatformButton.get_selected_id()
	
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().clear()
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Clean Godot Bindings", Submenu.CleanBindings)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Clean Current Library", Submenu.CleanCurrentLibrary)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().connect("id_pressed", self, "_on_Submenu_id_pressed")
	
	add_tooltip($BuildSystemButton, "Select which build system will be used to build your code.")
	add_tooltip($PlatformContainer/PlatformButton, "The platform to build for.")
	add_tooltip($PlatformContainer/ConfigurationButton, "The configuration to build for.")
	add_tooltip($CompilerButton, "The compiler used when building.")
	add_tooltip($MenuContainer/RefreshButton, "Check again if all required components are installed.")
	add_tooltip($MenuContainer/BuildMenuContainer/BuildBindingsButton, "Build the Godot bindings for the current configuration.")
	add_tooltip($MenuContainer/BuildMenuContainer/GenerateVSButton, "Generate and open the Visual Studio project.")
	add_tooltip($MenuContainer/BuildMenuContainer/BuildLibraryButton, "Build the currently selected library.")
	add_tooltip($MenuContainer/BuildMenuContainer/NewLibraryButton, "Create a new GDNative library.")
	add_tooltip($MenuContainer/BuildMenuContainer/SubmenuButton, "Additional functions...")
	add_tooltip($LibraryContainer/CurrentLibraryButton, "The current GDNative library which will be built.")
	
	var atfunc := funcref(self, "add_tooltip")
	$StatusContainer/PythonStatus.add_tooltip(atfunc, "Python is required to run SCons.")
	$StatusContainer/PipStatus.add_tooltip(atfunc, "pip is required to install SCons automatically.")
	$StatusContainer/SConsStatus.add_tooltip(atfunc, "SCons is the selected build tool.")
	$StatusContainer/GitStatus.add_tooltip(atfunc, "Git is required to check out the godot-cpp files and headers. You can also download them yourself.")
	$StatusContainer/CppStatus.add_tooltip(atfunc, "The godot-cpp files are required to build your code.")
	$StatusContainer/HeaderStatus.add_tooltip(atfunc, "The godot header files are required to build your code and must bne placed inside the godot-cpp folder.")
	$StatusContainer/CompilerStatus.add_tooltip(atfunc, "A compiler is needed to compile your code.")
	
	check_sdk_state()


func init_optionbutton(button :OptionButton, enumtype, defvalue :int = 0) -> void:
	button.clear()
	
	for k in enumtype.keys():
		button.add_item(k)
	
	button.select(defvalue)


func init_optionbutton_setting(button :OptionButton, setting :String, enumtype, defvalue :int = 0) -> void:
	init_optionbutton(button, enumtype, defvalue)
	
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
	needs_python = buildsystem == BuildSystem.SCons
	needs_pip    = buildsystem == BuildSystem.SCons
	needs_scons  = buildsystem == BuildSystem.SCons
	
	# handle python
	if needs_python:
		pythonpath = check_installation("Python", funcref(self, "find_python"), setting_pythonpath, false, exefilter)
		has_python = utils.file_exists(pythonpath)
	
	# handle pip
	if needs_pip:
		has_pip = find_pythonmodule("pip")
	
	# handle SCons
	if needs_scons:
		has_scons = find_pythonmodule("SCons")
	
	# handle godot-cpp
	gdcpppath = check_installation("godot-cpp", funcref(self, "find_godotcpp"), setting_gdcpppath, true)
	has_gdcpp = utils.file_exists(gdcpppath + gdcpppath_testfile)
	
	needs_git = not has_gdcpp  # or not has_gdheaders
	
	# handle git
	if needs_git:
		gitpath = check_installation("Git", funcref(self, "find_git"), setting_gitpath, false, exefilter)
		has_git = utils.file_exists(gitpath)
	
	# handle godot headers
	gdheaderspath = gdcpppath + "/godot-headers"
	has_gdheaders = utils.file_exists(gdheaderspath + gdheaderspath_testfile)
	
	# handle compiler
	compiler = -1
	$CompilerButton.clear()
	
	if utils.is_windows():
		if has_vs2015:
			$CompilerButton.add_item("Visual Studio 2015", Compiler.VisualStudio2015)
		
		if has_vs2017:
			$CompilerButton.add_item("Visual Studio 2017", Compiler.VisualStudio2017)
		
		if has_vs2019:
			$CompilerButton.add_item("Visual Studio 2019", Compiler.VisualStudio2019)
	
	if len($CompilerButton.items) > 0:
		compiler = $CompilerButton.get_selected_id()
	
	has_compiler = compiler >= 0
	
	needs_git = not has_gdcpp  # or not has_gdheaders
	needs_pip = not has_scons
	
	var wants_scons := needs_scons and not has_scons
	
	allgood = not wants_scons and has_gdcpp and has_gdheaders and has_compiler
	
	$PlatformLabel.visible = allgood
	$PlatformContainer.visible = allgood
	$MenuContainer/BuildMenuContainer.visible = allgood
	
	if allgood:
		$StatusContainer.visible = false
		
		$LibraryContainer/CurrentLibraryButton.clear()
		
		gdnlibs = { }
		var gdnatives := utils.find_resources("res://", "SConstruct", true)
		for gdn in gdnatives:
			var label = gdn.get_base_dir().get_file()
			gdnlibs[label] = gdn
			$LibraryContainer/CurrentLibraryButton.add_item(label)
		
		if len(gdnatives) > 0:
			currentgdnlib = gdnatives[0]
			
			$LibraryContainer/CurrentLibraryPathLabel.text = currentgdnlib.get_base_dir()
		
		$LibraryContainer.visible = true
	
	else:
		$LibraryContainer.visible = false
		
		var is_windows := utils.is_windows()
		var canfix_python := not is_windows  # or not pythonpath_windowsstore.empty()
		var canfix_pip := not is_windows
		var canfix_scons := has_pip
		var canfix_git := not is_windows
		
		$StatusContainer/PythonStatus.visible = needs_python
		$StatusContainer/PipStatus.visible = needs_pip
		$StatusContainer/SConsStatus.visible = needs_scons
		$StatusContainer/GitStatus.visible = needs_git
		
		$StatusContainer/PythonStatus.set_status(has_python, true, canfix_python)
		$StatusContainer/PipStatus.set_status(has_pip, true, canfix_pip)
		$StatusContainer/CompilerStatus.set_status(has_compiler, true, true)
		$StatusContainer/SConsStatus.set_status(has_scons, true, canfix_scons)
		$StatusContainer/GitStatus.set_status(has_git, true, canfix_git)
		$StatusContainer/CppStatus.set_status(has_gdcpp, true, has_git)
		$StatusContainer/HeaderStatus.set_status(has_gdheaders, true, false)
		
		$StatusContainer.visible = true


static func check_installation(name :String, findfunc :FuncRef, setting_name :String, isfolder :bool, filter :String = "") -> String:
	var searched := false
	
	var path = utils.get_project_setting(setting_name, TYPE_STRING, "", PROPERTY_HINT_GLOBAL_DIR if isfolder else PROPERTY_HINT_GLOBAL_FILE, filter)
	
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
	var output := []
	OS.execute("where" if utils.is_windows() else "which", [exename], true, output)
	
	var lines := utils.get_outputlines(output)
	
	if len(lines) > 0:
		return lines[0]
	
	return ""


func find_pythonmodule(module :String) -> bool:
	if not has_python:
		return false
	
	var output := []
	OS.execute(pythonpath, ["-m", module, "--version"], true, output)
	
	var lines := utils.get_outputlines(output)
	
	return len(lines) > 0 and not ("No module named" in lines[0])  # lines[0].begins_with(module)


func find_python() -> String:
	var exe := find_executable("python")
	
	if not exe.empty():
		if utils.file_exists(exe):
			return exe
			
		if utils.is_windows():
			# Under Windows 10, this opens the store
			pythonpath_windowsstore = exe
	
	return ""


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


func run_batch(name :String, batch :Array) -> int:
	var ext := ".bat" if utils.is_windows() else ".sh"
	var fname := "%s/%s_%d%s" % [temppath, name, random.randi(), ext]
	
	var file := File.new()
	file.open(fname, File.WRITE)
	
	for l in batch:
		file.store_string(l)
	
	file.close()
	
	print("Running \"" + fname + "\"...")
	
	var res :int
	
	if utils.is_windows():
		res = OS.execute(runinterminalpath, ["--run", fname], true)
	
	else:
		var output := []
		
		res = OS.execute(fname, [], true, output)
		
		var outlines := utils.get_outputlines(output)
		
		for l in outlines:
			print(l)
	
	return res


func find_vcvars(vsfolder :String) -> String:
	var editions := ["Enterprise", "Professional", "Community", "WDExpress"]
	var file := File.new()
	
	for e in editions:
		var f = vsfolder + "\\" + e + "\\VC\\Auxiliary\\Build\\vcvarsall.bat"
		
		if file.file_exists(f):
			return f
	
	return ""


func get_vcvars(comp :int) -> String:
	match comp:
		Compiler.VisualStudio2015:
			return find_vcvars(vs2015path)
		
		Compiler.VisualStudio2017:
			return find_vcvars(vs2017path)
		
		Compiler.VisualStudio2019:
			return find_vcvars(vs2019path)
	
	return ""


func run_makefile(name :String, folder :String, additionalargs :Array = []):
	var plat := ""
	var arch := ""
	var trgt := ""
	var bits := "64"
	
	match platform:
		BuildPlatform.Win32:
			plat = "windows"
			arch = "x86"
			bits = "32"
		
		BuildPlatform.Win64:
			plat = "windows"
			arch = "amd64"
	
	match buildcfg:
		BuildConfiguration.Shipping:
			trgt = "release"
		
		BuildConfiguration.Release:
			trgt = "release"
		
		BuildConfiguration.Profiling:
			trgt = "release_debug"
		
		BuildConfiguration.Debug:
			trgt = "debug"
			
	var args := [
		"-j4",
		"platform=" + plat,
		"target=" + trgt,
		"arch=" + bits,
		"bits=" + bits
	]
	
	args.append_array(additionalargs)
	
	var cpp := get_shortpath(gdcpppath)
	var hdr := get_shortpath(gdheaderspath)
	var argstr := PoolStringArray(args).join(" ")
	
	run_batch(name, [
		"@echo off\n",
		"cd \"" + folder + "\"\n",
		"call \"" + get_vcvars(compiler) + "\" " + arch + "\n",
		
		"set CPP_BINDINGS=\"" + cpp + "\"\n",
		"set GODOT_HEADERS=\"" + hdr + "\"\n",
		"\"" + pythonpath + "\" -m SCons " + argstr + "\n",
		"pause\n"
	])


func center_in_editor(ctrl :Control) -> void:
	ctrl.set_position( (editorbase.get_rect().size - ctrl.get_rect().size) / 2 )


func copy_files(from :String, to :String) -> bool:
	if utils.is_windows():
		return OS.execute("xcopy", ["/y", "/e", from.replace("/", "\\"), to.replace("/", "\\")], true) == 0
	else:
		# TODO: Support linux
		return false


func get_shortpath(path :String) -> String:
	if utils.is_windows():
		var output := []
		OS.execute(shortpathpath, [path], true, output)
		return output[0].strip_edges(false, true)
	
	return path


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


func _on_PipStatus_fix_pressed():
	# TODO: Support linux
	pass


func _on_PipStatus_www_pressed():
	OS.shell_open("https://www.python.org/downloads/")


func _on_SConsStatus_fix_pressed():
	OS.execute(pythonpath, ["-m", "pip", "install", "SCons"], true)
	
	check_sdk_state()


func _on_SConsStatus_www_pressed():
	OS.shell_open("https://scons.org/pages/download.html")


func _on_GitStatus_fix_pressed():
	# TODO: Support linux
	pass


func _on_GitStatus_www_pressed():
	OS.shell_open("https://git-scm.com/downloads")


func _on_CompilerStatus_fix_pressed():
	if utils.is_windows():
		OS.execute(toolspath + "/vs_wdexpress.exe", [], false)


func _on_CompilerStatus_www_pressed():
	if utils.is_windows():
		OS.shell_open("https://visualstudio.microsoft.com/vs/older-downloads/")
	else:
		# TODO: Support linux
		pass


func _on_CppStatus_fix_pressed():
	if has_git:
		git_clone(["clone", "--recurse-submodules", "--branch", godotversion, gdcppgiturl, gdcpppath])
		
	check_sdk_state()


func _on_CppStatus_www_pressed():
	OS.shell_open("https://github.com/godotengine/godot-cpp")


func _on_HeaderStatus_www_pressed():
	OS.shell_open("https://github.com/godotengine/godot-headers")


func _on_BuildBindingsButton_pressed():
	run_makefile("bindings", gdcpppath, ["generate_bindings=yes"])


func _on_PlatformButton_item_selected(index):
	platform = $PlatformContainer/PlatformButton.get_selected_id()


func _on_CompilerButton_item_selected(index):
	compiler = $CompilerButton.get_selected_id()


func _on_ConfigurationButton_item_selected(index):
	buildcfg = $PlatformContainer/ConfigurationButton.get_selected_id()


func _on_Submenu_id_pressed(id):
	match id:
		Submenu.CleanBindings:
			run_makefile("bindings-clean", gdcpppath, ["--clean"])
		Submenu.CleanCurrentLibrary:
			if not utils.file_exists(currentgdnlib):
				return
	
			var path := ProjectSettings.globalize_path(currentgdnlib)
			
			run_makefile("lib-clean", path.get_base_dir(), ["--clean"])


func _on_CurrentLibraryButton_item_selected(index):
	currentgdnlib = gdnlibs[ $LibraryContainer/CurrentLibraryButton.text ]
	
	$LibraryContainer/CurrentLibraryPathLabel.text = currentgdnlib.get_base_dir()


func _on_NewLibraryButton_pressed():
	center_in_editor($NewLibraryFileDialog)
	
	$NewLibraryFileDialog.popup()


func _on_NewLibraryFileDialog_dir_selected(dir):
	print("Creating new library in path \"" + dir + "\".")
	
	var dirlocal := ProjectSettings.globalize_path(dir)
	
	copy_files(templatespath + "/gdnative", dirlocal)
	
	check_sdk_state()


func _on_GenerateVSButton_pressed():
	if not utils.file_exists(currentgdnlib):
		return
	
	var path := ProjectSettings.globalize_path(currentgdnlib)
	
	run_makefile("vsproj", path.get_base_dir(), ["vsproj=yes"])


func _on_BuildLibraryButton_pressed():
	if not utils.file_exists(currentgdnlib):
		return
	
	var path := ProjectSettings.globalize_path(currentgdnlib)
	
	run_makefile("lib", path.get_base_dir(), [])
