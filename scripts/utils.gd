extends Object


static func is_windows() -> bool:
	return OS.get_name() == "Windows"


static func file_exists(file :String) -> bool:
	return not file.empty() and File.new().file_exists(file)


static func folder_exists(folder :String) -> bool:
	return not folder.empty() and Directory.new().file_exists(folder)


static func make_dir(path :String) -> void:
	Directory.new().make_dir_recursive(path)


static func get_project_setting(name :String, type :int, defvalue, hint :int = PROPERTY_HINT_NONE, hintstr :String = ""):
	if ProjectSettings.has_setting(name):
		return ProjectSettings.get(name)
		
	ProjectSettings.set_setting(name, defvalue)
	ProjectSettings.add_property_info({
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hintstr
	})
	ProjectSettings.set_initial_value(name, defvalue)
	
	return defvalue


static func get_project_setting_enum(name :String, enumtype, defvalue :int = 0) -> int:
	return get_project_setting(name, TYPE_INT, defvalue, PROPERTY_HINT_ENUM, get_enumoptions(enumtype))


static func get_enumoptions(enumtype) -> String:
	var s := str(enumtype.keys())
	return s.substr(1, len(s) - 2).replace(" ", "")


static func execute_shell(cmd :String) -> int:
	print("Running " + cmd)
	
	return OS.execute("cmd.exe", ["/C", cmd])


static func get_outputlines(output :Array) -> Array:
	var lines := []
	
	for o in output:
		var ol = o.split("\n", false)
		
		for l in ol:
			lines.append( l.strip_edges() )
	
	return lines
