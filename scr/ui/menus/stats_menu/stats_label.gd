## TODO Better Display
extends Label


func _update():
	text = Stats.as_text()


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_update()
