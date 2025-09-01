class_name SaveManager
extends MarginContainer
const SAVE_CONTAINER_SCENE_PATH = "res://scr/ui/start_menu/save_container.tscn"
const SAVE_CONTAINER_SCENE = preload("res://scr/ui/start_menu/save_container.tscn")
const SaveContainer = preload("res://scr/ui/start_menu/save_container.gd")


static func has_saves() -> bool:
	var dir = DirAccess.open(SL.save_directory_path)
	var error := DirAccess.get_open_error()
	if error == ERR_INVALID_PARAMETER:
		var global_path := ProjectSettings.globalize_path(SL.save_directory_path)
		DirAccess.make_dir_recursive_absolute(global_path)
		Log.info("create save directory at " + global_path)
		return false
	elif not dir or not dir.get_files():
		return false
	return true


func _ready() -> void:
	_try_load_saves()


func _try_load_saves() -> void:
	if not has_saves():
		return
	var dir := SL.simple_open_dir(SL.save_directory_path)
	if not dir:
		return
	await _add_save_containers(dir)
	for i in _get_saves():
		i.title.button_group = _save_button_group


var _save_button_group := ButtonGroup.new()


func _add_save_containers(dir: DirAccess) -> void:
	var last_container: SaveContainer
	for save_name in dir.get_files():
		if not save_name.ends_with(".json"):
			continue
		var container: SaveContainer = SAVE_CONTAINER_SCENE.instantiate()
		container.set_save(save_name)
		last_container = container
		%Container.add_child.call_deferred(container)
	await Lib.ensure_ready(last_container)


func _get_saves() -> Array[SaveContainer]:
	var result: Array[SaveContainer] = []
	result.assign(%Container.get_children())
	return result


func _get_selected_save() -> SaveContainer:
	var button: BaseButton = _save_button_group.get_pressed_button()
	return button.get_parent() if button else null


static func get_save_name_from_time() -> String:
	var new_save_name = Time.get_datetime_string_from_system()
	new_save_name = new_save_name.replace(":", "-")
	return new_save_name


@onready var accept_dialog: AcceptDialog = $AcceptDialog


func _pop_up_deletion_warning() -> void:
	accept_dialog.popup_centered()
	accept_dialog.confirmed.connect(_on_deletion_confirmed, CONNECT_ONE_SHOT)


func _on_deletion_confirmed():
	_get_selected_save().delete_this_save()


func _on_deletion_canceled() -> void:
	for i in accept_dialog.confirmed.get_connections():
		accept_dialog.confirmed.disconnect(i["callable"])


func _on_load_pressed() -> void:
	if _get_selected_save():
		Lib.change_scene_to(Main.SCENE_PATH)
		SL.load_game(_get_selected_save().save_name)
