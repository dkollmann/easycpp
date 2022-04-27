@tool
extends HBoxContainer

@export var filepath :String :
	get:
		return $LineEdit.text
	set(v):
		$LineEdit.text = v

@export var filter :String
@export var directory :bool

func _ready():
	pass

func getfile(currentpath :String, filter :String = ""):
	$LineEdit.text = currentpath
	$FileDialog.filename = currentpath
	$FileDialog.filters = filter


func _on_ToolButton_pressed():
	pass # Replace with function body.


func _on_FileDialog_dir_selected(dir):
	pass # Replace with function body.


func _on_FileDialog_file_selected(path):
	pass # Replace with function body.
