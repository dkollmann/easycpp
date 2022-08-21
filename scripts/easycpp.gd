@tool
extends VBoxContainer

enum BuildSystem {
	SCons,
	Cmake
}

const DefaultBuildPlatforms := [
	# Variables:
	# %name%      - The name of the GDNative library
	# %platform%  - The platform argument
	# %arch%      - The arch argument
	# %bits%      - The bits argument
	# %target%    - The name of the selected target
	# %compiler%  - The name of the selected compiler
	# %use_msvc%  - Is true when MSVC is the selected compiler
	# %use_clang% - Is true when Clang is the selected compiler
	# %use_gcc%   - Is true when GCC is the selected compiler
	
	"# name | enabled | available on | arguments | defines | outputname | gdnlibkey | vsplatform",
	"Windows (32-bit) | false | Windows | platform=windows arch=x86   bits=32 use_mingw=%use_gcc% | WIN32 | lib%name%.%platform%.%target%.%bits%.dll | Windows.32 | x86",
	"Windows (64-bit) | true  | Windows | platform=windows arch=amd64 bits=64 use_mingw=%use_gcc% | | lib%name%.%platform%.%target%.%bits%.dll | Windows.64 | x64",
	"Universal Windows Platform (32-bit) | false | Windows | platform=uwp arch=x86   bits=32 | WIN32 | lib%name%.%platform%.%target%.%bits%.dll | UWP.32 | x86",
	"Universal Windows Platform (64-bit) | false | Windows | platform=uwp arch=amd64 bits=64 | | lib%name%.%platform%.%target%.%bits%.dll | UWP.64 | x64",
	"Universal Windows Platform (ARM)    | false | Windows | platform=uwp arch=arm   bits=32 | | lib%name%.%platform%.%target%.%bits%.dll | UWP.arm | arm",
	"Universal Windows Platform (ARM64)  | false | Windows | platform=uwp arch=arm64 bits=64 | | lib%name%.%platform%.%target%.%bits%.dll | UWP.arm64 | arm64",
	"Linux (32-bit) | false | X11 | platform=linux bits=32 use_llvm=%use_clang% | | lib%name%.%platform%.%target%.%bits%.so | X11.32 | ",
	"Linux (64-bit) | true  | X11 | platform=linux bits=64 use_llvm=%use_clang% | | lib%name%.%platform%.%target%.%bits%.so | X11.64 | ",
	"macOS (32-bit) | false | OSX | platform=osx bits=32 | | lib%name%.%platform%.%target%.%bits%.so | OSX.32 | ",
	"macOS (64-bit) | true  | OSX | platform=osx bits=64 | | lib%name%.%platform%.%target%.%bits%.so | OSX.64 | ",
	"macOS (ARM64)  | true  | OSX | platform=osx arch=arm64 bits=64 | | lib%name%.%platform%.%target%.%bits%.so | OSX.arm64 | ",
	"Android (armeabi-v7a) | true  | Windows X11 OSX | platform=android arch=armv7   bits=32 | | lib%name%.%platform%.%target%.%arch%.so | Android.armeabi-v7a | ",
	"Android (arm64-v8a)   | true  | Windows X11 OSX | platform=android arch=arm64v8 bits=64 | | lib%name%.%platform%.%target%.%arch%.so | Android.arm64-v8a | ",
	"Android (x86)         | false | Windows X11 OSX | platform=android arch=x86     bits=32 | | lib%name%.%platform%.%target%.%arch%.so | Android.x86 | ",
	"Android (x86_64)      | false | Windows X11 OSX | platform=android arch=x86_64  bits=64 | | lib%name%.%platform%.%target%.%arch%.so | Android.x86_64 | ",
	"iOS (armv7)  | false | OSX | platform=ios arch=armv7  bits=32 | | lib%name%.%platform%.%target%.%arch%.so | iOS.armv7 | ",
	"iOS (arm64)  | true  | OSX | platform=ios arch=arm64  bits=64 | | lib%name%.%platform%.%target%.%arch%.so | iOS.arm64 | ",
	"iOS (x86_64) | true  | OSX | platform=ios arch=x86_64 bits=64 | | lib%name%.%platform%.%target%.%arch%.so | iOS.x86_64 | ",
	"HTML5 | true | Windows X11 OSX | platform=javascript | | lib%name%.%platform%.%target%.wasm32 | HTML5.wasm32 | "
]

const DefaultBuildConfigurations := [
	"# name | enabled | arguments | defines | use debug libs",
	"Shipping  | false | target=shipping tools=no | NDEBUG SHIPPING=1 | false",
	"Release   | true  | target=release | NDEBUG | false",
	"Profiling | false | target=release_debug | NDEBUG PROFILING=1 | false",
	"Debug     | true  | target=debug | _DEBUG | true"
]

enum BuildAction {
	Build,
	Clean,
	COUNT
}

const BuildActionStrings = [
	"-build",
	"-clean"
]

enum Compiler {
	VisualStudio2015,
	VisualStudio2017,
	VisualStudio2019,
	GCC,
	Clang,
	Xcode
}

const CompilerNames := [
	"vs2015",
	"vs2017",
	"vs2019",
	"gcc",
	"clang",
	"xcode"
]

enum Submenu {
	CleanBindings,
	CleanCurrentLibrary,
	CleanAll,
	GenerateAllBatchfiles,
	UpdateGDNativeLibrary
}

enum BatchfilesLocation {
	TemporaryFolder,
	BuildFolder
}

enum VisualProjectLocation {
	TemporaryFolder,
	ProjectFolder,
	BuildFolder
}

const supportCmake := false
const allowMacOSSConsFix := true

const settingsscene := preload("res://addons/easycpp/scenes/settings.tscn")
var utils := preload("res://addons/easycpp/scripts/utils.gd").new()

const toolsres := "res://addons/easycpp/tools"
const tempres := "res://addons/easycpp/temp"
const templatesres := "res://addons/easycpp/templates"

const gdcpppath_testfile := "/include/godot_cpp/godot.hpp"
const gdheaderspath_testfile := "/godot/gdnative_interface.h"
const gdcppgiturl = "https://github.com/godotengine/godot-cpp.git"

const linuxpause = "read -p \"Press any key to resume ...\"\n"

var editorbase #:Control

var vs2015path :String
var vs2017path :String
var vs2019path :String

var gccpath :String
var clangpath :String

var toolspath :String
var runinterminalpath :String
var shortpathpath :String
var temppath :String
var buildfolderpath :String
var templatespath :String
var pythonpath :String
var pythonpath_windowsstore :String
var cmakepath :String
var gitpath :String
var gdcpppath :String
var gdheaderspath :String

var has_vs2015 := false
var has_vs2017 := false
var has_vs2019 := false

var has_gcc := false
var has_clang := false
var has_xcode := false

var has_python := false
var has_pip := false
var has_scons := false
var has_cmake := false
var has_git := false
var has_gdcpp := false
var has_gdheaders := false
var has_compiler := false

var needs_python := true
var needs_pip := true
var needs_scons := true
var needs_cmake := true
var needs_git := true

var allgood := false

var buildplatforms :Array
var buildconfigurations :Array
var buildsystem :int = BuildSystem.SCons
var platform :BuildPlatform
var buildcfg :BuildConfiguration
var compiler :int = -1
var selecting_compiler := false

var gdnlibs := { }
var currentgdnlib :String
var currentgdnlib_name :String

var godotversion :String
var godotversiontag :String

var random := RandomNumberGenerator.new()
var settingswindow :SettingsWindow


func _ready():
	utils.run_tests()
	
	var ver := Engine.get_version_info()
	godotversion = str(ver.major) + "." + str(ver.minor)
	
	godotversiontag = godotversion
	
	var gittag := utils.get_project_setting_string(Constants.setting_gitversiontag)
	
	if not gittag.is_empty():
		godotversiontag = gittag
	
	random.randomize()
	
	# make sure the settings exists
	get_batchfilelocation()
	get_overwrite_makefiles()
	
	if utils.system == ECPP_Utils.System.Windows:
		# make sure the settings exists
		get_vsproj_location()
		get_vsproj_subfolder()
	
	toolspath = ProjectSettings.globalize_path(toolsres)
	templatespath = ProjectSettings.globalize_path(templatesres)
	runinterminalpath = toolspath + "/rit.exe"
	shortpathpath = toolspath + "/shortpath.bat"
	
	# handle cmake support
	$BuildSystemLabel.visible = supportCmake
	$BuildSystemButton.visible = supportCmake
	$Spacer6.visible = supportCmake
	
	if supportCmake:
		init_optionbutton_setting($BuildSystemButton, Constants.setting_buildsystem, BuildSystem)
	
	# create sub-menu
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().clear()
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Clean Godot Bindings", Submenu.CleanBindings)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Clean Current Library", Submenu.CleanCurrentLibrary)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Clean all Libraries", Submenu.CleanAll)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Generate all Batchfiles", Submenu.GenerateAllBatchfiles)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().add_item("Update GDNativeLibrary", Submenu.UpdateGDNativeLibrary)
	$MenuContainer/BuildMenuContainer/SubmenuButton.get_popup().connect("id_pressed", Callable(self, "_on_Submenu_id_pressed"))
	
	# add tooltips
	add_tooltip($BuildSystemButton, "Select which build system will be used to build your code.")
	add_tooltip($PlatformContainer/PlatformButton, "The platform to build for.")
	add_tooltip($PlatformContainer/ConfigurationButton, "The configuration to build for.")
	add_tooltip($CompilerButton, "The compiler used when building.")
	add_tooltip($MenuContainer/RefreshButton, "Check again if all required components are installed.")
	add_tooltip($MenuContainer/BuildMenuContainer/BuildBindingsButton, "Build the Godot bindings for the current configuration.")
	add_tooltip($MenuContainer/BuildMenuContainer/GenerateVSButton, "Generate and open Visual Studio solution.")
	add_tooltip($MenuContainer/BuildMenuContainer/GenerateQtButton, "Generate and open Qt Creator project.")
	add_tooltip($MenuContainer/BuildMenuContainer/BuildLibraryButton, "Build the currently selected library.")
	add_tooltip($MenuContainer/BuildMenuContainer/BuildAllButton, "Build all libraries.")
	add_tooltip($MenuContainer/BuildMenuContainer/NewLibraryButton, "Create a new GDNative library.")
	add_tooltip($MenuContainer/BuildMenuContainer/SettingsButton, "The most important settings.")
	add_tooltip($MenuContainer/BuildMenuContainer/SubmenuButton, "Additional functions...")
	add_tooltip($LibraryContainer/CurrentLibraryButton, "The current GDNative library which will be built.")
	
	var atfunc := Callable(self, "add_tooltip")
	$StatusContainer/PythonStatus.add_tooltip(atfunc, "Python is required to run SCons.")
	$StatusContainer/PipStatus.add_tooltip(atfunc, "pip is required to install SCons automatically.")
	$StatusContainer/SConsStatus.add_tooltip(atfunc, "SCons is the selected build tool.")
	$StatusContainer/CmakeStatus.add_tooltip(atfunc, "Cmake is the selected build tool.")
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
	ctrl.connect("mouse_entered", Callable(self, "_on_tooltip_show").bind(tooltip))
	ctrl.connect("mouse_exited", Callable(self, "_on_tooltip_hide"))
	
	if ctrl.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		ctrl.mouse_filter = Control.MOUSE_FILTER_STOP


func randomstring() -> String:
	return str(random.randi())


func randomuuid() -> String:
	return utils.get_uuid( randomstring() )


func read_build_platforms_configurations():
	# load platforms
	print("Reading Easy C++ Build Platforms...")
	
	var platforms := ""
	
	if not ProjectSettings.has_setting(Constants.setting_buildplatforms):
		platforms = "\n".join(DefaultBuildPlatforms)
	
	platforms = utils.get_project_setting_string(Constants.setting_buildplatforms, platforms, PROPERTY_HINT_MULTILINE_TEXT)
	
	buildplatforms = BuildFactory.new().parse_csv_pltfrm(platforms)
	
	if len(buildplatforms) < 1:
		print("Failed to load build platforms from settings!!")
	
	# load configurations
	print("Reading Easy C++ Build Configurations...")
	
	var configurations := ""
	
	if not ProjectSettings.has_setting(Constants.setting_buildconfigurations):
		configurations = "\n".join(DefaultBuildConfigurations)
	
	configurations = utils.get_project_setting_string(Constants.setting_buildconfigurations, configurations, PROPERTY_HINT_MULTILINE_TEXT)
	
	buildconfigurations = BuildFactory.new().parse_csv_cfg(configurations)
	
	if len(buildconfigurations) < 1:
		print("Failed to load build configurations from settings!!")


func check_sdk_state() -> void:
	# handle temporary folder
	temppath = ProjectSettings.globalize_path(tempres)
	temppath = utils.get_project_setting_string(Constants.setting_temppath, temppath, PROPERTY_HINT_GLOBAL_DIR)
	
	# handle build folder
	buildfolderpath = ProjectSettings.globalize_path( utils.get_project_setting_string(Constants.setting_buildfolder, "res://build", PROPERTY_HINT_GLOBAL_DIR) )
	
	print("Easy C++ temporary folder: \"" + temppath + "\".")
	print("Easy C++ build folder: \"" + buildfolderpath + "\".")
	
	read_build_platforms_configurations()
	
	# update the buttons and try to keep the current platform and configuration selected
	$PlatformContainer/PlatformButton.clear()
	$PlatformContainer/ConfigurationButton.clear()
	
	var pname := platform.name if platform != null else ""
	var cname := buildcfg.name if buildcfg != null else ""
	
	platform = null
	buildcfg = null
	
	for b in buildplatforms:
		$PlatformContainer/PlatformButton.add_item(b.name, b.index)
		
		if b.name == pname:
			platform = b
	
	for b in buildconfigurations:
		$PlatformContainer/ConfigurationButton.add_item(b.name, b.index)
		
		if b.name == cname:
			buildcfg = b
	
	if platform == null and len(buildplatforms) > 0:
		platform = buildplatforms[0]
	
	if buildcfg == null and len(buildconfigurations) > 0:
		buildcfg = buildconfigurations[0]
	
	var exefilter := "*.exe,*.bat,*.cmd" if utils.system == ECPP_Utils.System.Windows else "*"
	
	# prepare check
	needs_python = buildsystem == BuildSystem.SCons
	needs_pip    = buildsystem == BuildSystem.SCons
	needs_scons  = buildsystem == BuildSystem.SCons
	needs_cmake  = buildsystem == BuildSystem.Cmake
	
	# handle python
	if needs_python:
		pythonpath = check_installation("Python", Callable(self, "find_python"), Constants.setting_pythonpath, false, exefilter)
		has_python = utils.file_exists(pythonpath)
	
	# handle pip
	if needs_pip:
		has_pip = find_pythonmodule("pip")
	
	# handle SCons
	if needs_scons:
		has_scons = find_pythonmodule("SCons")
	
	# handle Cmake
	if needs_cmake:
		cmakepath = check_installation("Cmake", Callable(self, "find_cmake"), Constants.setting_cmakepath, false, exefilter)
		has_cmake = utils.file_exists(cmakepath)
	
	# handle godot-cpp
	gdcpppath = check_installation("godot-cpp", Callable(self, "find_godotcpp"), Constants.setting_gdcpppath, true)
	has_gdcpp = utils.file_exists(gdcpppath + gdcpppath_testfile)
	
	needs_git = not has_gdcpp  # or not has_gdheaders
	
	# handle git
	if needs_git:
		gitpath = check_installation("Git", Callable(self, "find_git"), Constants.setting_gitpath, false, exefilter)
		has_git = utils.file_exists(gitpath)
	
	# handle godot headers
	gdheaderspath = gdcpppath + "/godot-headers"
	has_gdheaders = utils.file_exists(gdheaderspath + gdheaderspath_testfile)
	
	# handle compiler
	var selected_compiler := compiler
	$CompilerButton.clear()
	
	match utils.system:
		ECPP_Utils.System.Windows:
			vs2015path = utils.get_project_setting_string(Constants.setting_vs2015path, "C:\\Program Files (x86)\\Microsoft Visual Studio 14.0", PROPERTY_HINT_GLOBAL_DIR)
			vs2017path = utils.get_project_setting_string(Constants.setting_vs2017path, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017", PROPERTY_HINT_GLOBAL_DIR)
			vs2019path = utils.get_project_setting_string(Constants.setting_vs2019path, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019", PROPERTY_HINT_GLOBAL_DIR)
			
			has_vs2015 = not find_vcvars(vs2015path).is_empty()
			has_vs2017 = not find_vcvars(vs2017path).is_empty()
			has_vs2019 = not find_vcvars(vs2019path).is_empty()
			
			if has_vs2015:
				$CompilerButton.add_item("Visual Studio 2015", Compiler.VisualStudio2015)
			
			if has_vs2017:
				$CompilerButton.add_item("Visual Studio 2017", Compiler.VisualStudio2017)
			
			if has_vs2019:
				$CompilerButton.add_item("Visual Studio 2019", Compiler.VisualStudio2019)
		
		ECPP_Utils.System.Linux:
			# always suport gcc and clang
			$CompilerButton.add_item("GCC", Compiler.GCC)
			$CompilerButton.add_item("Clang", Compiler.Clang)
		
		ECPP_Utils.System.macOS:
			has_xcode = false
			var output := []
			if OS.execute("/usr/bin/xcodebuild", ["-version"], output, true) == 0:
				var lines := utils.get_outputlines(output)
				if len(lines) > 0 and lines[0].begins_with("Xcode"):
					var xcode = lines[0].strip_edges(false, true)
					print("Found \"" + xcode + "\".")
					
					$CompilerButton.add_item(xcode, Compiler.Xcode)
					has_xcode = true
	
	# show or hide Visual Studio project button
	$MenuContainer/BuildMenuContainer/GenerateVSButton.visible = has_vs2015 or has_vs2017 or has_vs2019
	
	gccpath = check_installation("GCC", Callable(self, "find_gcc"), Constants.setting_gccpath, false, exefilter)
	clangpath = check_installation("Clang", Callable(self, "find_clang"), Constants.setting_clangpath, false, exefilter)
	
	has_gcc = utils.file_exists(gccpath)
	has_clang = utils.file_exists(clangpath)
	
	selecting_compiler = true
	
	if selected_compiler >= 0 and utils.optionbutton_select_id($CompilerButton, selected_compiler) >= 0:
		compiler = selected_compiler
	else:
		if $CompilerButton.item_count > 0:
			compiler = $CompilerButton.get_selected_id()
		else:
			compiler = -1
	
	selecting_compiler = false
	
	if utils.system == ECPP_Utils.System.Windows:
		has_compiler = compiler >= 0
	else:
		has_compiler = false
		match compiler:
			Compiler.GCC:
				has_compiler = has_gcc
			Compiler.Clang:
				has_compiler = has_clang
			Compiler.Xcode:
				has_compiler = has_xcode
	
	needs_git = not has_gdcpp  # or not has_gdheaders
	needs_pip = not has_scons
	
	var wants_scons := needs_scons and not has_scons
	var wants_cmake := needs_cmake and not has_cmake
	
	allgood = not wants_scons and not wants_cmake and has_gdcpp and has_gdheaders and has_compiler
	
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
			currentgdnlib_name = currentgdnlib.get_base_dir().get_file()
			
			$LibraryContainer/CurrentLibraryPathLabel.text = currentgdnlib.get_base_dir()
		
		$LibraryContainer.visible = true
	
	else:
		$LibraryContainer.visible = false
		
		var is_windows :bool = utils.system == ECPP_Utils.System.Windows
		var canfix_python := not is_windows or not pythonpath_windowsstore.is_empty()
		var canfix_pip := false
		var canfix_scons := has_pip
		var canfix_cmake := not is_windows
		var canfix_git := not is_windows
		
		match utils.system:
			ECPP_Utils.System.Linux:
				canfix_pip = has_python and pythonpath.ends_with("python3")
			
			ECPP_Utils.System.macOS:
				canfix_pip = has_python and pythonpath == "/usr/bin/python"
		
		$StatusContainer/PythonStatus.visible = needs_python
		$StatusContainer/PipStatus.visible = needs_pip
		$StatusContainer/SConsStatus.visible = needs_scons
		$StatusContainer/CmakeStatus.visible = needs_cmake
		$StatusContainer/GitStatus.visible = needs_git
		
		$StatusContainer/PythonStatus.set_status(has_python, true, canfix_python)
		$StatusContainer/PipStatus.set_status(has_pip, true, canfix_pip)
		$StatusContainer/CompilerStatus.set_status(has_compiler, true, true)
		$StatusContainer/SConsStatus.set_status(has_scons, true, canfix_scons)
		$StatusContainer/CmakeStatus.set_status(has_cmake, true, canfix_cmake)
		$StatusContainer/GitStatus.set_status(has_git, true, canfix_git)
		$StatusContainer/CppStatus.set_status(has_gdcpp, true, has_git)
		$StatusContainer/HeaderStatus.set_status(has_gdheaders, true, false)
		
		$StatusContainer.visible = true


static func check_installation(name :String, findfunc :Callable, setting_name :String, isfolder :bool, filter :String = "") -> String:
	var searched := false
	
	var path := ECPP_Utils.get_project_setting_string(setting_name, "", PROPERTY_HINT_GLOBAL_DIR if isfolder else PROPERTY_HINT_GLOBAL_FILE, filter)
	
	if path.is_empty():
		searched = true
		path = findfunc.call()
	
	if (ECPP_Utils.folder_exists(path) if isfolder else ECPP_Utils.file_exists(path)):
		print("Found " + name + " path: \"" + path + "\".")
		
		if searched:
			ProjectSettings.set(setting_name, path)
			
	else:
		print("Could not find any version of " + name + "!")
	
	return path


func find_executable(exename :String) -> String:
	var output := []
	OS.execute("where" if utils.system == ECPP_Utils.System.Windows else "which", [exename], output, true)
	
	var lines := utils.get_outputlines(output)
	
	if len(lines) > 0:
		return lines[0]
	
	return ""


func find_pythonmodule(module :String) -> bool:
	if not has_python:
		return false
	
	var output := []
	OS.execute(pythonpath, ["-m", module, "--version"], output, true)
	
	var lines := utils.get_outputlines(output)
	
	return len(lines) > 0 and not ("No module named" in lines[0])  # lines[0].begins_with(module)


func find_python() -> String:
	var py := find_executable("python")
	
	if utils.system == ECPP_Utils.System.Windows:
		if not py.is_empty():
			if utils.file_exists(py):
				return py
				
			# Under Windows 10, this opens the store
			pythonpath_windowsstore = py
		
		return ""
	else:
		if not utils.file_exists(py):
			py = find_executable("python3")
	
	return py


func find_cmake() -> String:
	var exe := find_executable("cmake")
	
	if exe.is_empty() and utils.system == ECPP_Utils.System.Windows:
		var p := "C:\\Program Files\\CMake\\bin\\cmake.exe"
		if utils.file_exists(p):
			return p
	
	return ""


func find_git() -> String:
	return find_executable("git")


func find_gcc() -> String:
	return find_executable("gcc")


func find_clang() -> String:
	return find_executable("clang")

func find_godotcpp() -> String:
	return temppath + "/godot-cpp"


func git_defaultbranch() -> String:
	var branch := ""
	var output := []
	
	OS.execute(gitpath, ["config", "--get", "init.defaultbranch"], output, true)
	
	if len(output) > 0:
		branch = output[0].strip_edges(false, true)
	
	return branch


func git_fixdefaultbranch() -> void:
	var defbranch := git_defaultbranch()
	
	print("Git default branch: \"" + defbranch + "\".")
	
	if defbranch.is_empty():
		print("Trying to hotfix invalid default branch name issue...")
		
		var output := []
		OS.execute(gitpath, ["config", "--global", "init.defaultBranch", "master"], output, true, true)
		
		utils.print_outputlines(output)


func git_clone(sourceurl :String, targetpath :String, branch :String, tryfix :bool = true) -> bool:
	if not has_git:
		return false
	
	if tryfix:
		git_fixdefaultbranch()
	
	utils.make_dir(targetpath)
	
	var args := ["clone", "--recurse-submodules", "--branch", branch, sourceurl, targetpath]
	
	return run_shell("git_clone", gitpath, args) == 0


func run_shell(name :String, exe :String, args :Array = []) -> int:
	var pause := ""
	match utils.system:
		ECPP_Utils.System.Windows:
			pause = "pause"
		
		ECPP_Utils.System.Linux:
			pause = linuxpause
		
		ECPP_Utils.System.macOS:
			pass
	
	if utils.system == ECPP_Utils.System.Windows:
		exe = exe.replace("/", "\\")
		
		if exe.ends_with(".bat") or exe.ends_with(".cmd"):
			args.insert(0, exe)
			exe = "call"
	
	var args2 := args.duplicate()
	args2.insert(0, exe)
	
	var args_str := utils.arglist_to_string(args2)
	
	var batch :Array
	if utils.system == ECPP_Utils.System.Windows:
		batch = ["@echo off\n", args_str + "\n", pause]
	else:
		batch = [args_str + "\n", pause]
	
	var batchfile := create_batch_temp(name, batch)
	
	var terminal_exe := ""
	var terminal_args := []
	
	match utils.system:
		ECPP_Utils.System.Windows:
			terminal_exe = runinterminalpath
			terminal_args = ["--run", batchfile]
		
		ECPP_Utils.System.Linux:
			var terminal := ECPP_Utils.get_project_setting_string(Constants.setting_terminalpath, "/usr/bin/gnome-terminal -- %command%")
			var cmd := terminal.replace("%command%", "bash \"" + batchfile + "\"")
			
			terminal_args = utils.parse_args(cmd, true)
			terminal_exe = terminal_args.pop_front()
		
		ECPP_Utils.System.macOS:
			terminal_exe = "/usr/bin/open"
			terminal_args = ["-b", "com.apple.terminal", batchfile]
	
	var output := []
	var res := OS.execute(terminal_exe, terminal_args, output, true)
	
	var outlines := utils.get_outputlines(output)
	
	for l in outlines:
		print(l)
	
	return res


func install_package(package :String) -> int:
	return run_shell("install_package", "/usr/bin/sudo", ["apt", "install", package])


func get_batchfilelocation() -> int:
	return utils.get_project_setting_enum_keys(Constants.setting_batchfilelocation, ",".join(Constants.setting_batchfilelocation_items))


func get_batchfilefolder() -> String:
	if get_batchfilelocation() == BatchfilesLocation.TemporaryFolder:
		return temppath
	
	return buildfolderpath


func create_batch_build(name :String, batch :Array) -> String:
	if get_batchfilelocation() == BatchfilesLocation.TemporaryFolder:
		return create_batch_temp(name, batch)
	
	if not get_overwrite_makefiles():
		var fname := get_batch_filename(buildfolderpath, name)
		
		if File.new().file_exists(fname):
			return fname
	
	return create_batch_dir(buildfolderpath, name, batch)


func create_batch_temp(name :String, batch :Array) -> String:
	return create_batch_dir(temppath, name, batch)


func get_batch_filename(folder :String, name :String) -> String:
	return "%s/%s%s" % [folder, name, ".bat" if utils.system == ECPP_Utils.System.Windows else ".sh"]


func get_overwrite_makefiles() -> bool:
	return utils.get_project_setting_bool(Constants.setting_overwritemakefiles, true)

func create_batch_dir(folder :String, name :String, batch :Array) -> String:
	utils.make_dir_ignored(folder)
	
	var fname := get_batch_filename(folder, name)
	
	if create_batch(fname, batch):
		return fname
	
	return ""


func create_batch(fname :String, batch :Array) -> bool:
	print("Creating \"" + fname + "\"...")
	
	var file := File.new()
	if file.open(fname, File.WRITE) != OK:
		return false
	
	for l in batch:
		file.store_string(l)
	
	file.close()
	
	utils.make_executable(fname)
	
	return true


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


func create_makefile(pltfrm :BuildPlatform, bldcfg :BuildConfiguration, name :String, post :String, folder :String, additionalargs :Array = []) -> String:
	assert(not name.is_empty())
	
	var args := [
		"-j4",
		"cpp_bindings=\"" + gdcpppath + "\"",
		"godot_headers=\"" + gdheaderspath + "\""
	]
	
	args.append_array(pltfrm.arguments)
	args.append_array(bldcfg.arguments)
	args.append_array(additionalargs)
	
	var fname := get_buildoutput(name, pltfrm, bldcfg).get_basename() + post
	var cpp := get_shortpath(gdcpppath)
	var hdr := get_shortpath(gdheaderspath)
	var argstr := " ".join(args)
	
	argstr = apply_buildvariables(argstr, name, pltfrm, bldcfg)
	
	var batch := []
	
	if utils.system == ECPP_Utils.System.Windows:
		batch.append("@echo off\n")
	
	batch.append("cd \"" + folder + "\"\n")
	
	if utils.system == ECPP_Utils.System.Windows and not pltfrm.vsplatform.is_empty():
		batch.append("call \"" + get_vcvars(compiler) + "\" " + pltfrm.vsplatform + "\n")
	
	batch.append_array([
		"set CPP_BINDINGS=\"" + cpp + "\"\n",
		"set GODOT_HEADERS=\"" + hdr + "\"\n",
		"\"" + pythonpath + "\" -m SCons " + argstr + "\n"
	])
	
	return create_batch_build(fname, batch)


func apply_buildvariables(text :String, name :String, pltfrm :BuildPlatform, bldcfg :BuildConfiguration) -> String:
	var d := utils.join_dict(pltfrm.arguments_dict, bldcfg.arguments_dict)
	
	d["name"] = name
	d["compiler"] = CompilerNames[compiler]
	d["use_msvc"] = "True" if (compiler <= Compiler.VisualStudio2019) else "False"
	d["use_clang"] = "True" if compiler == Compiler.Clang else "False"
	d["use_gcc"] = "True" if compiler == Compiler.GCC else "False"
	
	return utils.apply_dict(text, d, "%")


func get_buildoutput(name :String, pltfrm :BuildPlatform, bldcfg :BuildConfiguration) -> String:
	return apply_buildvariables(pltfrm.outputname, name, pltfrm, bldcfg)


static func get_buildpreprocessors(pltfrm :BuildPlatform, bldcfg :BuildConfiguration) -> Array:
	return pltfrm.defines + bldcfg.defines


static func get_buildpreprocessors_str(pltfrm :BuildPlatform, bldcfg :BuildConfiguration) -> String:
	var list := get_buildpreprocessors(pltfrm, bldcfg)
	
	return ";".join(list)


static func get_buildpreprocessors_defines(pltfrm :BuildPlatform, bldcfg :BuildConfiguration) -> String:
	var list := get_buildpreprocessors(pltfrm, bldcfg)
	
	var s := ""
	for pp in list:
		s += "#define " + pp.replace("=", " ") + "\n"
	
	return s


static func get_buildconfig_index(platform :BuildPlatform, config :BuildConfiguration, action :int) -> int:
	return platform.index + config.index * 10 + action * 100


func create_all_makefiles_for_config(platform :BuildPlatform, config :BuildConfiguration, folder :String, lib :String, additionalargs :Array, batchfiles :Dictionary):
	var addargs := [
		[],
		["--clean"]
	]
	
	const count :int = BuildAction.COUNT
	
	for i in range(count):
		var make := create_makefile(platform, config, lib, BuildActionStrings[i], folder, additionalargs + addargs[i])
		
		batchfiles[ get_buildconfig_index(platform, config, i) ] = make


func create_all_makefiles_for_platform(platform :BuildPlatform, folder :String, lib :String, additionalargs :Array, batchfiles :Dictionary):
	for c in buildconfigurations:
		create_all_makefiles_for_config(platform, c, folder, lib, additionalargs, batchfiles)


func create_all_makefiles(folder :String, lib :String, additionalargs :Array = []) -> Dictionary:
	var batchfiles := {}
	
	for p in buildplatforms:
		create_all_makefiles_for_platform(p, folder, lib, additionalargs, batchfiles)
	
	return batchfiles


func create_bindings_makefiles() -> Dictionary:
	return create_all_makefiles(gdcpppath, "godot-bindings", ["generate_bindings=yes"])


func create_buildall_batchfiles() -> Dictionary:
	# generate all batch files
	var batchfiles := [ create_bindings_makefiles() ]
	
	for l in gdnlibs:
		var path := ProjectSettings.globalize_path(gdnlibs[l]).get_base_dir()
		
		batchfiles.append( create_all_makefiles(path, l) )
	
	# create "all" batch files
	var batchfolder := get_batchfilefolder()
	var buildallfiles := {}
	
	const count :int = BuildAction.COUNT
	
	for p in buildplatforms:
		for c in buildconfigurations:
			var fbase := get_buildoutput("all", p, c).get_basename()
			if fbase.begins_with("lib"):
				fbase = fbase.substr(3)
			
			for a in range(count):
				var idx := get_buildconfig_index(p, c, a)
				
				var batch := []
				
				if utils.system == ECPP_Utils.System.Windows:
					batch.append("@echo off\n")
				
				#batch.append("cd \"" + batchfolder + "\"\n")
				
				for b in batchfiles:
					var bfile = b[idx]  #.get_file()
					
					if utils.system == ECPP_Utils.System.Windows:
						batch.append("call \"" + bfile + "\"\n")
					else:
						batch.append("\"" + bfile + "\"\n")
				
				buildallfiles[idx] = create_batch_build(fbase + BuildActionStrings[a], batch)
	
	return buildallfiles


func run_makefile_dict(dict :Dictionary, platform :BuildPlatform, config :BuildConfiguration, action :int) -> int:
	var idx := get_buildconfig_index(platform, config, action)
	var fname = dict[idx]
	
	print("Running \"" + fname + "\"...")
	
	return run_shell("run_makefile", fname)


func run_makefile_dict_current(dict :Dictionary, action :int) -> int:
	return run_makefile_dict(dict, platform, buildcfg, action)


func center_in_editor(ctrl :Window) -> void:
	ctrl.position = (Vector2i(editorbase.size) - ctrl.size) / 2


func get_shortpath(path :String) -> String:
	if utils.system == ECPP_Utils.System.Windows:
		var output := []
		OS.execute(shortpathpath, [path], output, true)
		return output[0].strip_edges(false, true)
	
	return path


func update_gdnlib(gdnlibpath :String) -> bool:
	'''
	var gdnlibname := gdnlibpath.get_base_dir().get_file()
	var gdnlibrespath :String = gdnlibpath.get_base_dir() + "/bin/" + gdnlibname + ".gdnlib"
	var gdnlibres :GDNativeLibrary
	
	if File.new().file_exists(gdnlibrespath):
		print("Loading \"" + gdnlibrespath + "\"...")
		
		gdnlibres = load(gdnlibrespath)
		
	else:
		print("Creating \"" + gdnlibrespath + "\"...")
		
		gdnlibres = GDNativeLibrary.new()
	
	for p in buildplatforms:
		var value = gdnlibres.config_file.get_value("entry", p.gdnlibkey, "")
		if value.empty():
			var outname := get_buildoutput(gdnlibname, p, buildcfg)
			print("Setting " + p.gdnlibkey + " to " + outname)
			gdnlibres.config_file.set_value("entry", p.gdnlibkey, outname)
	
	print("Saving \"" + gdnlibrespath + "\"...")
	return ResourceSaver.save(gdnlibrespath, gdnlibres, ResourceSaver.FLAG_CHANGE_PATH) == OK
	'''
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
	if utils.system == ECPP_Utils.System.Windows:
		OS.execute(pythonpath_windowsstore, [])
	else:
		install_package("python3")
		
		check_sdk_state()


func _on_PythonStatus_www_pressed():
	OS.shell_open("https://www.python.org/downloads/")


func _on_PipStatus_fix_pressed():
	match utils.system:
		ECPP_Utils.System.Linux:
			install_package("python3-pip")
		
		ECPP_Utils.System.macOS:
			if pythonpath == "/usr/bin/python":
				run_shell("install_pip", pythonpath, ["-m", "ensurepip", "--user"])
	
	check_sdk_state()


func _on_PipStatus_www_pressed():
	OS.shell_open("https://www.python.org/downloads/")


func _on_SConsStatus_fix_pressed():
	match utils.system:
		ECPP_Utils.System.Linux:
			run_shell("install_scons", pythonpath, ["-m", "pip", "install", "SCons"])
		
		ECPP_Utils.System.macOS:
			var install := true
			
			if allowMacOSSConsFix:
				var site := utils.get_userfolder() + "/Library/Python/2.7/lib/python/site-packages"
				var scons_bad := site + "/scons/SCons"
				var scons_good := site + "/SCons"
				
				var dir := Directory.new()
				if dir.dir_exists(scons_bad):
					install = false
					
					print("Found incorrectly installed SCons at \"" + scons_bad + "\"...")
					print("Moving to \"" + scons_good + "\"...")
					
					var output := []
					
					if OS.execute("/bin/mv", [site + "/scons", site + "/scons__"], output, true) == 0:
						print("Renamed incorrect SCons folder...")
						
						if OS.execute("/bin/mv", [site + "/scons__/SCons", scons_good], output, true) == 0:
							print("Moved SCons to correct folder \"" + scons_good + "\"...")
			
			if install:
				run_shell("install_scons", pythonpath, ["-m", "pip", "install", "SCons", "pathlib", "--user"])
	
	check_sdk_state()


func _on_SConsStatus_www_pressed():
	OS.shell_open("https://scons.org/pages/download.html")


func _on_CmakeStatus_fix_pressed():
	# TODO: Support linux
	pass


func _on_CmakeStatus_www_pressed():
	OS.shell_open("https://cmake.org/download/")


func _on_GitStatus_fix_pressed():
	if utils.system == ECPP_Utils.System.Linux:
		install_package("git")
		
		check_sdk_state()


func _on_GitStatus_www_pressed():
	OS.shell_open("https://git-scm.com/downloads")


func _on_CompilerStatus_fix_pressed():
	match utils.system:
		ECPP_Utils.System.Windows:
			var output := []
			
			OS.execute(toolspath + "/vs_wdexpress.exe", [], output, false)
		
		ECPP_Utils.System.Linux:
			match compiler:
				Compiler.GCC:
					install_package("gcc")
				
				Compiler.Clang:
					install_package("clang")
		
		ECPP_Utils.System.macOS:
			OS.shell_open("https://apps.apple.com/us/app/xcode/id497799835")


func _on_CompilerStatus_www_pressed():
	match utils.system:
		ECPP_Utils.System.Windows:
			OS.shell_open("https://visualstudio.microsoft.com/vs/older-downloads/")
		
		ECPP_Utils.System.Linux:
			pass
		
		ECPP_Utils.System.macOS:
			OS.shell_open("https://developer.apple.com/xcode/resources/")


func _on_CppStatus_fix_pressed():
	if has_git:
		git_clone(gdcppgiturl, gdcpppath, godotversiontag)
		
	check_sdk_state()


func _on_CppStatus_www_pressed():
	OS.shell_open("https://github.com/godotengine/godot-cpp")


func _on_HeaderStatus_www_pressed():
	OS.shell_open("https://github.com/godotengine/godot-headers")


func _on_BuildBindingsButton_pressed():
	var batchfiles := create_bindings_makefiles()
	
	run_makefile_dict_current(batchfiles, BuildAction.Build)


func _on_PlatformButton_item_selected(index):
	platform = buildplatforms[index]


func _on_CompilerButton_item_selected(index):
	if selecting_compiler:
		return
	
	compiler = $CompilerButton.get_selected_id()
	
	check_sdk_state()


func _on_ConfigurationButton_item_selected(index):
	buildcfg = buildconfigurations[index]


func _on_Submenu_id_pressed(id):
	match id:
		Submenu.CleanBindings:
			var batchfiles := create_bindings_makefiles()
			
			run_makefile_dict_current(batchfiles, BuildAction.Clean)
		
		Submenu.CleanCurrentLibrary:
			if not utils.file_exists(currentgdnlib):
				return
			
			var path := ProjectSettings.globalize_path(currentgdnlib).get_base_dir()
			
			var batchfiles := create_all_makefiles(path, currentgdnlib_name)
			
			run_makefile_dict_current(batchfiles, BuildAction.Clean)
		
		Submenu.CleanAll:
			var batchfiles := create_buildall_batchfiles()
			
			run_makefile_dict_current(batchfiles, BuildAction.Clean)
		
		Submenu.GenerateAllBatchfiles:
			create_buildall_batchfiles()
		
		Submenu.UpdateGDNativeLibrary:
			update_gdnlib(currentgdnlib)


func _on_CurrentLibraryButton_item_selected(index):
	currentgdnlib = gdnlibs[ $LibraryContainer/CurrentLibraryButton.text ]
	currentgdnlib_name = currentgdnlib.get_base_dir().get_file()
	
	$LibraryContainer/CurrentLibraryPathLabel.text = currentgdnlib.get_base_dir()


func _on_NewLibraryButton_pressed():
	center_in_editor($NewLibraryFileDialog)
	
	$NewLibraryFileDialog.popup()


func _on_NewLibraryFileDialog_dir_selected(dir :String):
	print("Creating new library in path \"" + dir + "\".")
	
	var dirlocal := ProjectSettings.globalize_path(dir)
	var path := dirlocal + "/SConstruct"
	
	utils.copy_files(templatespath + "/gdnative", dirlocal)
	
	var f := File.new()
	if f.open(dirlocal + "/SConstruct", File.READ) == OK:
		var content := f.get_as_text()
		f.close()
		
		content = content.replace("$$libname$$", dir.get_file())
		
		if f.open(path, File.WRITE) == OK:
			f.store_string(content)
			f.close()
	
	update_gdnlib(path)
	
	check_sdk_state()


func get_vsproj_location() -> int:
	return utils.get_project_setting_enum_keys(Constants.setting_vsproj_location, ",".join(Constants.setting_vsproj_location_items))


func get_vsproj_subfolder() -> String:
	return utils.get_project_setting_string(Constants.setting_vsproj_subfolder)


func _on_GenerateVSButton_pressed():
	print("Generating Visual Studio projects and solution...")
	
	# determine some settings
	var location := get_vsproj_location()
	
	var folder_solution := ""
	var folder_projects := ""
	var perproject := true
	
	match location:
		VisualProjectLocation.TemporaryFolder:  # all files are placed in a temporary folder
			folder_solution = temppath + "/vsproj"
			folder_projects = folder_solution
			perproject = false
			print("  Files are placed in temporary folder: \"" + folder_solution + "\".")
		
		VisualProjectLocation.ProjectFolder:  # the solution is placed in the root and the project files are put in their individual folders
			folder_solution = ProjectSettings.globalize_path("res://")
			folder_projects = get_vsproj_subfolder()
			perproject = true
			print("  Files are placed in the project folders: \"" + folder_projects + "\".")
		
		VisualProjectLocation.BuildFolder:  # all files are placed in a build folder inside the project
			folder_solution = buildfolderpath
			folder_projects = folder_solution
			perproject = false
			print("  Files are placed in build folder: \"" + folder_solution + "\".")
	
	utils.make_dir(folder_solution)
	
	# collect supported platforms
	var vsbuildplatforms := []
	for p in buildplatforms:
		if not p.vsplatform.empty():
			vsbuildplatforms.append(p)
	
	# sort the build configurations
	var vsbuildconfigurations := buildconfigurations.duplicate()
	vsbuildconfigurations.sort_custom(Callable(BuildBase, "sort"))
	
	# generate the project configurations
	var projectconfigs := ""
	var projectconfigtypes := ""
	var projectuserprops := ""
	
	for p in vsbuildplatforms:
		assert(not p.vsplatform.empty())
		
		var pp = p.vsplatform
		
		for c in vsbuildconfigurations:
			var cc = c.name
			
			projectconfigs += "    <ProjectConfiguration Include=\"%s|%s\">\n" % [cc, pp]
			projectconfigs += "      <Configuration>%s</Configuration>\n" % [cc]
			projectconfigs += "      <Platform>%s</Platform>\n" % [pp]
			projectconfigs += "    </ProjectConfiguration>\n"
			
			projectconfigtypes += "  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='%s|%s'\" Label=\"Configuration\">\n" % [cc, pp]
			projectconfigtypes += "    <ConfigurationType>Makefile</ConfigurationType>\n"
			projectconfigtypes += "    <UseDebugLibraries>%s</UseDebugLibraries>\n" % ["true" if c.debuglibs else "false"]
			projectconfigtypes += "    <PlatformToolset>v142</PlatformToolset>\n"
			projectconfigtypes += "  </PropertyGroup>\n"
			
			projectuserprops += "  <ImportGroup Label=\"PropertySheets\" Condition=\"'$(Configuration)|$(Platform)'=='%s|%s'\">\n" % [cc, pp]
			projectuserprops += "    <Import Project=\"$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\" Condition=\"exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')\" Label=\"LocalAppDataPlatform\" />\n"
			projectuserprops += "  </ImportGroup>\n"
	
	# start generating files
	var f := File.new()
	
	var projects := gdnlibs.duplicate()
	projects["godot-bindings"] = gdcpppath + "/SConstruct"
	
	var uuids := {}
	var projectfiles := {}
	
	for lib in projects:
		var libdir := ProjectSettings.globalize_path( projects[lib].get_base_dir() )
		var outdir :=  libdir if perproject else folder_solution
		
		print("  Collecting source files for \"" + lib + "\"...")
		
		var sourcesdir := libdir + "/src"
		
		var headerfiles := []
		var sourcefiles := []
		var headerfolders := []
		var sourcefolders := []
		utils.find_sourcefiles(sourcesdir, true, headerfiles, sourcefiles, headerfolders, sourcefolders, utils.system == ECPP_Utils.System.Windows)
		
		var headerfiles_str := ""
		var sourcefiles_str := ""
		var headerfolders_str := ";".join(headerfolders)
		var sourcefolders_str := ";".join(sourcefolders)
		
		for h in headerfiles:
			headerfiles_str += "    <ClInclude Include=\"" + h + "\" />\n"
		
		for s in sourcefiles:
			sourcefiles_str += "    <ClCompile Include=\"" + s + "\" />\n"
		
		
		print("  Generating project for \"" + lib + "\"...")
		
		var batchfiles :Dictionary
		
		if lib == "godot-bindings":
			batchfiles = create_bindings_makefiles()
		else:
			batchfiles = create_all_makefiles(libdir, lib)
		
		var projectnmakes := ""
		
		for p in vsbuildplatforms:
			assert(not p.vsplatform.empty())
			
			var pp = p.vsplatform
			
			for c in vsbuildconfigurations:
				var cc = c.name
				
				var nmake_build = batchfiles[ get_buildconfig_index(p, c, BuildAction.Build) ]
				var nmake_clean = batchfiles[ get_buildconfig_index(p, c, BuildAction.Clean) ]
				var preprocs := get_buildpreprocessors_str(p, c)
				
				projectnmakes += "  <PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='%s|%s'\">\n" % [cc, pp]
				projectnmakes += "    <NMakeOutput>" + get_buildoutput(lib, p, c) + "</NMakeOutput>\n"
				projectnmakes += "    <NMakeBuildCommandLine>\"" + nmake_build + "\"</NMakeBuildCommandLine>\n"
				projectnmakes += "    <NMakeCleanCommandLine>\"" + nmake_clean + "\"</NMakeCleanCommandLine>\n"
				projectnmakes += "    <NMakeReBuildCommandLine>\"" + nmake_clean + "\" &amp;&amp; \"" + nmake_build + "\"</NMakeReBuildCommandLine>\n"
				projectnmakes += "    <NMakePreprocessorDefinitions>" + preprocs + ";$(NMakePreprocessorDefinitions)</NMakePreprocessorDefinitions>\n"
				projectnmakes += "    <NMakeIncludeSearchPath>" + gdheaderspath + ";$(NMakeIncludeSearchPath)</NMakeIncludeSearchPath>\n"
				projectnmakes += "    <PublicIncludeDirectories>" + headerfolders_str + "</PublicIncludeDirectories>\n"
				projectnmakes += "    <PublicModuleDirectories>" + sourcefolders_str + "</PublicModuleDirectories>\n"
				projectnmakes += "  </PropertyGroup>\n"
		
		if f.open(templatespath + "/vsproj/template.vcxproj", File.READ) == OK:
			var content := f.get_as_text()
			f.close()
			
			var uuid := utils.get_uuid(lib)
			
			uuids[lib] = uuid
			
			content = content.replace("$$projectguid$$", uuid)
			content = content.replace("$$projectconfigs$$", projectconfigs.strip_edges(false, true))
			content = content.replace("$$projectconfigtypes$$", projectconfigtypes.strip_edges(false, true))
			content = content.replace("$$projectuserprops$$", projectuserprops.strip_edges(false, true))
			content = content.replace("$$projectnmakes$$", projectnmakes.strip_edges(false, true))
			content = content.replace("$$headerfiles$$", headerfiles_str.strip_edges(false, true))
			content = content.replace("$$sourcefiles$$", sourcefiles_str.strip_edges(false, true))
			
			var outfile = outdir + "/" + lib + ".vcxproj"
			
			projectfiles[lib] = outfile
			
			if f.open(outfile, File.WRITE) == OK:
				f.store_string(content)
				f.close()
		
		
		print("  Generating filters for \"" + lib + "\"...")
		
		if f.open(templatespath + "/vsproj/template.vcxproj.filters", File.READ) == OK:
			var content := f.get_as_text()
			f.close()
			
			content = content.replace("$$sourcefilesguid$$", randomuuid())
			content = content.replace("$$headerfilesguid$$", randomuuid())
			
			var outfile = outdir + "/" + lib + ".vcxproj.filters"
			
			if f.open(outfile, File.WRITE) == OK:
				f.store_string(content)
				f.close()
	
	print("  Generating solution...")
	
	var projectstr := ""
	var configspresolution := ""
	var configspostsolution := ""
	
	for p in vsbuildplatforms:
			assert(not p.vsplatform.empty())
			
			var pp = p.vsplatform
			
			for c in vsbuildconfigurations:
				var cc = c.name
				
				configspresolution += "\t\t%s|%s = %s|%s\n" % [cc, pp, cc, pp]
	
	for p in projects:
		var suuid := utils.get_uuid(p)
		
		# add the extra 4 digits
		suuid = suuid.substr(0, 33) + "0000}"
		
		projectstr += "Project(\"%s\") = \"%s\", \"%s\", \"%s\"\nEndProject\n" % [uuids[p], p, projectfiles[p], suuid]
		
		for pt in vsbuildplatforms:
			assert(not pt.vsplatform.empty())
			
			var pp = pt.vsplatform
			
			for c in vsbuildconfigurations:
				var cc = c.name
				
				configspostsolution += "\t\t%s.%s|%s.ActiveCfg = %s|%s\n" % [suuid, cc, pp, cc, pp]
				configspostsolution += "\t\t%s.%s|%s.Build.0 = %s|%s\n" % [suuid, cc, pp, cc, pp]
	
	var solutionname := utils.get_projectname()
	var solutionfile = folder_solution + "/" + solutionname + ".sln"
	
	if f.open(templatespath + "/vsproj/template.sln", File.READ) == OK:
			var content := f.get_as_text()
			f.close()
			
			content = content.replace("$$projects$$", projectstr.strip_edges(false, true))
			content = content.replace("$$configspresolution$$", configspresolution.strip_edges(false, true))
			content = content.replace("$$configspostsolution$$", configspostsolution.strip_edges(false, true))
			content = content.replace("$$solutionguid$$", utils.get_uuid(solutionname))
			
			if f.open(solutionfile, File.WRITE) == OK:
				f.store_string(content)
				f.close()
	
	OS.shell_open(solutionfile)


func _on_BuildLibraryButton_pressed():
	if not utils.file_exists(currentgdnlib):
		return
	
	var path := ProjectSettings.globalize_path(currentgdnlib).get_base_dir()
	
	var batchfiles := create_all_makefiles(path, currentgdnlib_name)
	
	run_makefile_dict_current(batchfiles, BuildAction.Build)


func _on_BuildAllButton_pressed():
	var batchfiles := create_buildall_batchfiles()
	
	run_makefile_dict_current(batchfiles, BuildAction.Build)


func _on_GenerateQtButton_pressed():
	if not utils.file_exists(currentgdnlib):
		return
	
	print("Generating Qt Creator project for the selected platform and configuration...")
	
	var f := File.new()
	
	var libdir := ProjectSettings.globalize_path( currentgdnlib.get_base_dir() )	
	var sourcesdir := libdir + "/src"
	
	var headerfiles := []
	var sourcefiles := []
	utils.find_sourcefiles(sourcesdir, true, headerfiles, sourcefiles)
	
	var root := ProjectSettings.globalize_path(temppath)  + "/qtcreator"
	var base := root + "/" + get_buildoutput(currentgdnlib_name, platform, buildcfg).get_basename()
	
	utils.make_dir(root)
	
	var includes := []
	utils.find_includefolders(gdcpppath + "/include", true, includes)
	utils.find_includefolders(gdheaderspath, true, includes)
	
	var creator_path := base + ".creator"
	var creator_content := "[General]\n"
	
	var cflags_path := base + ".cflags"
	var cflags_content := "-std=c14"
	
	var cxxflags_path := base + ".cxxflags"
	var cxxflags_content := "-std=c14"
	
	var config_path := base + ".config"
	var config_content := get_buildpreprocessors_defines(platform, buildcfg)
	
	var includes_path := base + ".includes"
	var includes_content := "\n".join(includes)
	
	var files_path := base + ".files"
	var files_content := "\n".join(headerfiles + sourcefiles)
	
	if f.open(creator_path, File.WRITE) == OK:
		f.store_string(creator_content)
		f.close()
	
	if f.open(cflags_path, File.WRITE) == OK:
		f.store_string(cflags_content)
		f.close()
	
	if f.open(cxxflags_path, File.WRITE) == OK:
		f.store_string(cxxflags_content)
		f.close()
	
	if f.open(config_path, File.WRITE) == OK:
		f.store_string(config_content)
		f.close()
	
	if f.open(includes_path, File.WRITE) == OK:
		f.store_string(includes_content)
		f.close()
	
	if f.open(files_path, File.WRITE) == OK:
		f.store_string(files_content)
		f.close()
	
	print("Created project \"" + creator_path + "\".")
	
	OS.shell_open(creator_path)


func _on_SettingsButton_pressed():
	assert(settingswindow == null)
	
	settingswindow = settingsscene.instantiate()
	settingswindow.set_size(editorbase.get_rect().size * 0.5)
	settingswindow.load_settings(utils)
	
	settingswindow.connect("close_requested", Callable(self, "_on_Settings_close"))
	settingswindow.connect("visibility_changed", Callable(self, "_on_Settings_hide"))
	
	add_child(settingswindow)
	center_in_editor(settingswindow)
	
	settingswindow.popup()


func _on_Settings_hide():
	assert(settingswindow != null)
	
	if not settingswindow.visible:
		_on_Settings_close()


func _on_Settings_close():
	assert(settingswindow != null)
	
	print("Settings closed")
	
	remove_child(settingswindow)
	
	if settingswindow.save:
		check_sdk_state()
	
	settingswindow = null
