extends Object
class_name Utils


enum System {
	Windows,
	Linux,
	macOS
}

var system :int

func _init():
	var s := OS.get_name()
	
	if s == "Windows":
		system = System.Windows
	elif s == "X11":
		system = System.Linux
	elif s == "OSX":
		system = System.macOS


static func file_exists(file :String) -> bool:
	return not file.empty() and File.new().file_exists(file)


static func folder_exists(folder :String) -> bool:
	return not folder.empty() and Directory.new().dir_exists(folder)


static func make_dir(path :String) -> void:
	Directory.new().make_dir_recursive(path)


static func make_dir_ignored(path :String) -> void:
	Directory.new().make_dir_recursive(path)
	
	var fn := path + "/.gdignore"
	var f := File.new()
	
	if not f.file_exists(fn):
		f.open(fn, File.WRITE)
		f.close()


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


static func get_project_setting_enum_keys(name :String, keys :String, defvalue :int = 0) -> int:
	return get_project_setting(name, TYPE_INT, defvalue, PROPERTY_HINT_ENUM, keys)


static func get_project_setting_flags(name :String, enumtype, defvalue :int = 0) -> int:
	return get_project_setting(name, TYPE_INT, defvalue, PROPERTY_HINT_FLAGS, get_enumoptions(enumtype))


static func get_project_setting_flags_keys(name :String, keys :String, defvalue :int = 0) -> int:
	return get_project_setting(name, TYPE_INT, defvalue, PROPERTY_HINT_FLAGS, keys)


static func get_project_setting_bool(name :String, defvalue :bool) -> bool:
	return get_project_setting(name, TYPE_BOOL, defvalue)


static func get_project_setting_string(name :String, defvalue :String = "", hint :int = PROPERTY_HINT_NONE, hintstr :String = "") -> String:
	return get_project_setting(name, TYPE_STRING, defvalue, hint, hintstr).strip_edges()


static func get_enumoptions(enumtype) -> String:
	var s := str(enumtype.keys())
	return s.substr(1, len(s) - 2).replace(" ", "")


static func get_outputlines(output :Array) -> Array:
	var lines := []
	
	for o in output:
		var ol = o.split("\n", false)
		
		for l in ol:
			lines.append( l.strip_edges() )
	
	return lines


static func print_outputlines(output :Array) -> Array:
	var lines := get_outputlines(output)
	
	for l in lines:
		print(l)
	
	return lines


static func select_folder(folders :Array) -> String:
	for f in folders:
		if folder_exists(f):
			return f
	
	return folders[0]


static func select_file(root :String, files :Array) -> String:
	for f in files:
		var ff = root + "/" + f
		if file_exists(ff):
			return ff
	
	return root + "/" + files[0]


static func find_resources(path :String, fileext :String, recursive :bool) -> Array:
	var folders := [path]
	var files := []
	var dir := Directory.new()
	
	for f in folders:
		if dir.file_exists(f + "/.gdignore"):
			continue
		
		dir.open(f)
		dir.list_dir_begin(true, true)
		
		var file := dir.get_next()
		while file != '':
			var p = f + "/" + file
			
			if dir.dir_exists(p):
				folders.append(p)
			
			elif file.ends_with(fileext):
				files.append(p)
			
			file = dir.get_next()
		
		dir.list_dir_end()
	
	return files


static func find_sourcefiles(path :String, recursive :bool, headerfiles :Array, sourcefiles :Array) -> void:
	var folders := [path]
	var dir := Directory.new()
	
	for f in folders:
		dir.open(f)
		dir.list_dir_begin(true, true)
		
		var file := dir.get_next()
		while file != '':
			var p = f + "/" + file
			
			if dir.dir_exists(p):
				folders.append(p)
			
			else:
				var ext := file.get_extension()
				
				if ext == "c" or ext == "cc" or ext == "cpp":
					sourcefiles.append(p)
				
				elif ext == "h" or ext == "hpp":
					headerfiles.append(p)
			
			file = dir.get_next()
		
		dir.list_dir_end()


static func find_includefolders(path :String, recursive :bool, includes :Array) -> void:
	var folders := [path]
	var dir := Directory.new()
	
	for f in folders:
		dir.open(f)
		dir.list_dir_begin(true, true)
		
		var folderadded := false
		
		var file := dir.get_next()
		while file != '':
			var p = f + "/" + file
			
			if dir.dir_exists(p):
				folders.append(p)
			
			elif not folderadded:
				var ext := file.get_extension()
				
				if ext == "h" or ext == "hpp":
					includes.append(f)
					folderadded = true
			
			file = dir.get_next()
		
		dir.list_dir_end()


static func get_uuid(input :String) -> String:
	var md5 := input.md5_text().to_upper()
	
	return "{%s-%s-%s-%s-%s}" % [md5.substr(0, 8), md5.substr(8, 4), md5.substr(12, 4), md5.substr(16, 4), md5.substr(20, 8)]


static func hasbit(bits :int, value :int) -> bool:
	return (bits & (1 << value)) != 0


static func get_projectname() -> String:
	return ProjectSettings.get_setting("application/config/name")


static func split_clean(text :String, delimiter :String, allow_empty :bool = true) -> PoolStringArray:
	var values := text.split(delimiter, allow_empty)
	
	for i in range(len(values)):
		values[i] = values[i].strip_edges()
	
	return values


static func parse_csvdata(csv :String) -> Array:
	var data := []
	var lines := csv.split("\n", false)
	
	# check if we have data
	if len(lines) < 2:
		return data
	
	var keysstr := lines[0].strip_edges(true, false)
	
	# check if the first line are the keys
	if not keysstr.begins_with("#"):
		return data
	
	keysstr = keysstr.substr(1, len(keysstr)-1)
	
	var keys := split_clean(keysstr, "|", true)
	
	# check if all keys are valid
	for k in keys:
		if k.empty():
			return data
	
	# check datasets
	for i in range(1, len(lines)):
		if len(lines[i]) != len(keys):
			return data
	
	# parse data
	for i in range(1, len(lines)):
		var d := {}
		
		for j in range(len(keys)):
			d[ keys[j] ] = lines[i][j]
		
		data.append(d)
	
	return data


static func parse_args(args :String, stripquotes :bool) -> Array:
	var lst := []
	
	var lastpos := 0
	var start := 0
	var quotes := false
	
	while true:
		var pos := args.find(" ", lastpos)
		var pos2 := args.find("\"", lastpos)
		
		if quotes:
			if pos2 < 0:
				break
			
			if stripquotes and args[start] == '"':
				lst.append(args.substr(start + 1, pos2 - start - 1))
			else:
				lst.append(args.substr(start, pos2 - start + 1))
			
			quotes = false
			start = -1
			lastpos = pos2 + 1
		
		else:
			if pos2 >= 0 and pos2 < pos:
				quotes = true
				if start < 0:
					start = pos2
				lastpos = pos2 + 1
			else:
				if pos < 0:
					break
				
				if start >= 0:
					var ln := pos - start
					if ln > 0:
						lst.append(args.substr(start, ln))
				
				start = pos + 1
				lastpos = pos + 1
	
	if start >= 0 and start < len(args):
		lst.append(args.substr(start))
	
	return lst


func arglist_to_string(args :Array) -> String:
	var args2 := args.duplicate()
	var sep := "\\" if system == System.Windows else "/"
	
	for i in range(len(args2)):
		var a :String = args2[i]
		
		if " " in a and sep in a:
			args2[i] = '"' + a + '"'
	
	return PoolStringArray(args2).join(" ")


static func parse_args_dict(args :String, out :Dictionary, allow_nokey :bool) -> bool:
	# does not handle quotes
	var i := 0
	var alist := parse_args(args, true)
	
	for a in alist:
		var aa = a.split("=", true)
		
		if len(aa) < 1 or (len(aa) == 1 and not allow_nokey) or len(aa) > 2:
			return false
		
		if len(aa) < 2:
			out[i] = aa[0]
			i += 1
		else:
			out[aa[0]] = aa[1]
	
	return true


static func apply_dict(text :String, dict :Dictionary, marker :String = "%") -> String:
	var lastpos := 0
	var start := -1
	
	while true:
		var pos := text.find(marker, lastpos)
		
		if pos < 0:
			return text
		
		if start >= 0:
			var key := text.substr(start + 1, pos - start - 1)
			
			text = text.substr(0, start) + dict[key] + text.substr(pos + 1)
			
			lastpos = start
			start = -1
		else:
			start = pos
			lastpos = pos + 1
	
	return text


static func dict_to_array(dict :Dictionary) -> Array:
	var lst := []
	
	for key in dict:
		if key.typeof(TYPE_STRING):
			lst.append(key + "=" + dict[key])
		else:
			lst.append(dict[key])
	
	return lst


static func is_true(s :String) -> bool:
	var ss := s.strip_edges().to_lower()
	
	return ss != "false"


static func add_dict(d1 :Dictionary, d2 :Dictionary) -> void:
	for k in d2:
		d1[k] = d2[k]


static func join_dict(d1 :Dictionary, d2 :Dictionary) -> Dictionary:
	var d := d1.duplicate()
	
	add_dict(d, d2)
	
	return d


static func make_executable(exe :String) -> int:
	return OS.execute("/usr/bin/chmod", ["+x", exe], true)


static func optionbutton_select_id(button :OptionButton, id :int):
	if button.get_selected_id() == id:
		return button.selected
	
	for i in range(button.get_item_count()):
		if button.get_item_id(i) == id:
			button.select(i)
			return i
	
	return -1


static func run_tests():
	var l1 := parse_args(" a b  c \"hello world\" hello=\"world\" ", false)
	assert(len(l1) == 5)
	assert(l1[0] == "a")
	assert(l1[1] == "b")
	assert(l1[2] == "c")
	assert(l1[3] == "\"hello world\"")
	assert(l1[4] == "hello=\"world\"")
	
	var l2 := parse_args(" a b  c \"hello world\" hello=\"world\" ", true)
	assert(len(l2) == 5)
	assert(l2[0] == "a")
	assert(l2[1] == "b")
	assert(l2[2] == "c")
	assert(l2[3] == "hello world")
	assert(l2[4] == "hello=\"world\"")
