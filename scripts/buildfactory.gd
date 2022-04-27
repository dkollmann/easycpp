@tool
extends Object
class_name BuildFactory


static func parse_csv(csv :String, all :bool, createfunc :Callable) -> Array:
	var lst := []
	var lines := csv.split("\n", false)
	
	for i in range(len(lines)):
		var l := lines[i].strip_edges()
		
		if l.begins_with("#"):
			continue
		
		var params := ECPP_Utils.split_clean(l, "|", true)
		var b :BuildBase = createfunc.call(i, params, all)
		
		if b != null:
			lst.append(b)
	
	return lst


func parse_csv_pltfrm(csv :String, all :bool = false) -> Array:
	return parse_csv(csv, all, Callable(self, "create_pltfm"))


func parse_csv_cfg(csv :String, all :bool = false) -> Array:
	return parse_csv(csv, all, Callable(self, "create_cfg"))


func create_pltfm(idx :int, params :Array, all :bool) -> BuildPlatform:
	assert(len(params) == 8)
	
	# check if available and enabled
	var enabled := ECPP_Utils.is_true(params[1])
	var availableon = params[2]
	
	if all or (enabled and OS.get_name() in availableon):
		var p := BuildPlatform.new()
		
		p.index = idx
		p.name = params[0].strip_edges()
		p.enabled = enabled
		p.arguments = ECPP_Utils.parse_args(params[3], false)
		p.defines = ECPP_Utils.parse_args(params[4], false)
		p.availableon = availableon
		p.outputname = params[5]
		p.gdnlibkey = params[6].strip_edges()
		p.vsplatform = params[7].strip_edges()
		
		p.parse_arguments()
		
		return p
	
	return null


static func bool_str(v :bool) -> String:
	return "true" if v else "false"


static func makestr_pltfrm(bld :BuildPlatform) -> String:
	var cfg := [
		bld.name,
		bool_str(bld.enabled),
		bld.availableon,
		" ".join(bld.arguments),
		" ".join(bld.defines),
		bld.outputname,
		bld.gdnlibkey,
		bld.vsplatform,
	]
	
	return "|".join(cfg)


func create_cfg(idx :int, params :Array, all :bool) -> BuildConfiguration:
	assert(len(params) == 5)
	
	# check if enabled
	var enabled := ECPP_Utils.is_true(params[1])
	
	if all or enabled:
		var b := BuildConfiguration.new()
		
		b.index = idx
		b.name = params[0].strip_edges()
		b.enabled = enabled
		b.arguments = ECPP_Utils.parse_args(params[2], false)
		b.defines = ECPP_Utils.parse_args(params[3], false)
		b.debuglibs = ECPP_Utils.is_true(params[4])
		
		b.parse_arguments()
		
		return b
	
	return null


static func makestr_cfg(bld :BuildConfiguration) -> String:
	var cfg := [
		bld.name,
		bool_str(bld.enabled),
		" ".join(bld.arguments),
		" ".join(bld.defines),
		bool_str(bld.debuglibs),
	]
	
	return "|".join(cfg)
