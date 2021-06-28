tool
extends BuildBase
class_name BuildPlatform


var outputname :String
var gdnlibkey :String
var vsplatform :String

 
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


static func create(idx :int, line :String) -> BuildPlatform:
	var params := Utils.split_clean(line, "|", true)
	
	assert(len(params) == 8)
	
	# check if available and enabled
	var enabled := Utils.is_true(params[1])
	var availableon := params[2]
	
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
