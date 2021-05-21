tool
extends HBoxContainer

signal fix_pressed()
signal www_pressed()

export var icon :Texture setget set_icon2, get_icon2
export var text :String setget set_text, get_text

func set_icon2(v):
	$Icon.texture = v

func get_icon2():
	return $Icon.texture

func set_text(v):
	$Label.text = v

func get_text():
	return $Label.text

func set_status(good :bool, www :bool, fix :bool) -> void:
	$StatusGood.visible = good
	$StatusFix.visible = not good and fix
	$StatusWebsite.visible = not good and www

func add_tooltip(f :FuncRef, tooltip :String) -> void:
	f.call_func(self, tooltip)
	f.call_func($StatusFix, "Download and install the required files automatically.")
	f.call_func($StatusWebsite, "Open the browser and download the files manually.")

func _on_StatusWebsite_pressed():
	emit_signal("www_pressed")

func _on_StatusFix_pressed():
	emit_signal("fix_pressed")
