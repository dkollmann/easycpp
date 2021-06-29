tool
extends Control

export var tabtype :PackedScene

func generate_tabs(items :Array) -> void:
	for i in items:
		var t := tabtype.instance()
		
		t.setobj(i)
		
		$VBoxContainer/TabContainer.add_child(t)
