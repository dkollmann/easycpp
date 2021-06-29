tool
extends Control

export var tabtype :PackedScene


var tabs :Array = []


func generate_tabs(items :Array) -> void:
	for i in items:
		var t := tabtype.instance()
		
		t.setobj(i)
		
		tabs.append(t)
		
		$VBoxContainer/TabContainer.add_child(t)

func generate_objects() -> Array:
	var items := []
	
	for t in tabs:
		items.append( t.createobj() )
	
	return items
