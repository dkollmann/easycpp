@tool
extends Object
class_name BuildBase


var index :int
var name :String
var enabled :bool
var arguments :Array
var arguments_dict :Dictionary = {}
var defines :Array


static func sort(a, b):
	return a.name < b.name


func parse_arguments() -> void:
	for a in arguments:
		var p = a.find("=")
		var k = a.substr(0, p).strip_edges()
		var v = a.substr(p + 1).strip_edges()
		
		arguments_dict[k] = v
