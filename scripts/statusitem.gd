@tool
extends HBoxContainer

signal fix_pressed()
signal www_pressed()

@export var icon :Texture :
	get:
		return $Icon.texture
	set(v):
		$Icon.texture = v

@export var text :String :
	get:
		return $Label.text
	
	set(v):
		$Label.text = v


func set_status(good :bool, www :bool, fix :bool) -> void:
	$StatusGood.visible = good
	$StatusFix.visible = not good and fix
	$StatusWebsite.visible = not good and www

func add_tooltip(f :Callable, tooltip :String) -> void:
	f.call(self, tooltip)
	f.call($StatusFix, "Download and install the required files automatically.")
	f.call($StatusWebsite, "Open the browser and download the files manually.")

func _on_StatusWebsite_pressed():
	emit_signal("www_pressed")

func _on_StatusFix_pressed():
	emit_signal("fix_pressed")
