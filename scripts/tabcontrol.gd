@tool
extends Control

@export var tabtype :PackedScene


var tabs :Array = []


func update_tabs(remove :bool = true) -> void:
	if remove:
		for t in tabs:
			$VBoxContainer/TabContainer.remove_child(t)
	
	for t in tabs:
		$VBoxContainer/TabContainer.add_child(t)


func generate_tabs(items :Array) -> void:
	for i in items:
		var t := tabtype.instantiate()
		
		t.setobj(i)
		
		tabs.append(t)
	
	update_tabs(false)


func generate_objects() -> Array:
	var items := []
	
	for t in tabs:
		items.append( t.createobj() )
	
	return items


func _on_AddButton_pressed():
	var t := tabtype.instantiate()
	
	var bld = t.createnewobj()
	
	t.setobj(bld)
	
	tabs.insert(0, t)
	
	update_tabs()


func _on_DuplicateButton_pressed():
	var idx = $VBoxContainer/TabContainer.current_tab
	var bld = tabs[idx].createobj()
	
	var t := tabtype.instantiate()
	
	bld.name += " copy"
	t.setobj(bld)
	
	tabs.insert(idx + 1, t)
	
	update_tabs()
	
	$VBoxContainer/TabContainer.current_tab = idx + 1


func _on_DeleteButton_pressed():
	var idx = $VBoxContainer/TabContainer.current_tab
	
	$VBoxContainer/TabContainer.remove_child( tabs[idx] )
	
	tabs.remove_at(idx)
