tool
extends HBoxContainer

export var icon :Texture setget set_icon2, get_icon2
export var text :String setget set_text, get_text
export var status :Texture setget set_status, get_status

func set_icon2(v):
	$Icon.texture = v

func get_icon2() -> Texture:
	return $Icon.texture

func set_text(v):
	$Label.text = v

func get_text():
	return $Label.text

func set_status(v):
	$Status.texture = v

func get_status() -> Texture:
	return $Status.texture
