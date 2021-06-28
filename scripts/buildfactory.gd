tool
extends Object
class_name BuildFactory


static func parse_csv(csv :String, createfunc :FuncRef) -> Array:
	var lst := []
	var lines := csv.split("\n", false)
	
	for i in range(len(lines)):
		var l := lines[i].strip_edges()
		
		if l.begins_with("#"):
			continue
		
		var params := Utils.split_clean(l, "|", true)
		var b :BuildBase = createfunc.call_func(i, params)
		
		if b != null:
			lst.append(b)
	
	return lst


func parse_csv_pltfrm(csv :String) -> Array:
	return parse_csv(csv, funcref(self, "create_pltfm"))


func parse_csv_cfg(csv :String) -> Array:
	return parse_csv(csv, funcref(self, "create_cfg"))


func create_pltfm(idx :int, params :Array) -> BuildPlatform:
	assert(len(params) == 8)
	
	# check if available and enabled
	var enabled := Utils.is_true(params[1])
	var availableon = params[2]
	
	if enabled and OS.get_name() in availableon:
		var p := BuildPlatform.new()
		
		p.index = idx
		p.name = params[0].strip_edges()
		p.arguments = Utils.split_clean(params[3], " ", false)
		p.defines = Utils.split_clean(params[4], " ", false)
		p.outputname = params[5]
		p.gdnlibkey = params[6].strip_edges()
		p.vsplatform = params[7].strip_edges()
		
		p.parse_arguments()
		
		return p
	
	return null


func create_cfg(idx :int, params :Array) -> BuildConfiguration:
	assert(len(params) == 5)
	
	# check if enabled
	var enabled := Utils.is_true(params[1])
	
	if enabled:
		var b := BuildConfiguration.new()
		
		b.index = idx
		b.name = params[0].strip_edges()
		b.arguments = Utils.split_clean(params[2], " ", false)
		b.defines = Utils.split_clean(params[3], " ", false)
		b.debuglibs = Utils.is_true(params[4])
		
		b.parse_arguments()
		
		return b
	
	return null
