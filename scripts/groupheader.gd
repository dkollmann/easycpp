tool
extends GridContainer

export var text :String

func _enter_tree():
	$Label.text = text
