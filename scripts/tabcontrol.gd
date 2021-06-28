tool
extends Control

export var tabtype :PackedScene

func generate_tabs(csv :String) -> void:
	var lines := csv.split("\n", false)
	
	for l in lines:
		var t := tabtype.instance()
		
		t.readline(l)
		
		$VBoxContainer/TabContainer.add_child(t)
