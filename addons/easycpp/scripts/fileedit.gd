tool
extends HBoxContainer

export var filepath :String setget _set_filepath, _get_filepath
export var filter :String
export var directory :bool

func _ready():
	pass

func getfile(currentpath :String, filter :String = ""):
	$LineEdit.text = currentpath
	$FileDialog.filename = currentpath
	$FileDialog.filters = filter


func _set_filepath(v :String):
	$LineEdit.text = v


func _get_filepath() -> String:
	return $LineEdit.text


func _on_ToolButton_pressed():
	pass # Replace with function body.


func _on_FileDialog_dir_selected(dir):
	pass # Replace with function body.


func _on_FileDialog_file_selected(path):
	pass # Replace with function body.
