tool
extends BuildBase
class_name BuildConfiguration


var debuglibs :bool


static func parse_csv(csv :String) -> Array:
	var lst := []
	var lines := csv.split("\n", false)
	
	for i in range(len(lines)):
		var l := lines[i].strip_edges()
		
		if l.begins_with("#"):
			continue
		
		var b := create(i, l)
		
		if b != null:
			lst.append(b)
	
	return lst


static func create(idx :int, line :String) -> BuildConfiguration:
	var params := Utils.split_clean(line, "|", true)
	
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
