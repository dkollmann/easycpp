extends Object


static func is_windows() -> bool:
	return OS.get_name() == "Windows"


static func file_exists(file :String) -> bool:
	return File.new().file_exists(file)


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


static func get_project_setting_from_env(name :String, type :int, envvarname :String, defvalue :String, hint :int = PROPERTY_HINT_NONE, hintstr :String = ""):
	var v = get_project_setting(name, type, defvalue, hint, hintstr)
	
	if not v.empty():
		return v
			
	var ev = OS.get_environment(envvarname)
	
	ProjectSettings.set_setting(name, ev)
	
	return ev
