class_name SL
static var save_directory_path = "user://saves"
const SAVE_FILE_SUFFIX = "/%s.json"


static func save_game(save_name := Main.save_name):
	var to_save := {"room": Room.current, "player": Player.local_instance, "inventory": UI.instance.backpack}
	Log.info("Start saving")
	var save_path = save_directory_path + SAVE_FILE_SUFFIX % save_name
	var save_file = simple_open_file(save_path, FileAccess.WRITE)
	if not save_file:
		Log.error("Saving failed")
		return
	for name in to_save:
		Log.info("Saving " + name)
		to_save[name] = to_save[name].get_save()
	var json_string = JSON.stringify(to_save)
	save_file.store_line(json_string)
	Log.notice("Saving finished")


static func save_something(path: String, what: Object):
	Log.info("Start saving %s" % what)
	var save_file = simple_open_file(path, FileAccess.WRITE)
	if not save_file:
		Log.error("Saving failed")
		return
	var json_string = JSON.stringify(what)
	save_file.store_line(json_string)
	Log.info("Saving %s finished" % what)


static func load_game(save_name: String):
	Log.info("Start Loading Save")
	var save_path = save_directory_path + SAVE_FILE_SUFFIX % save_name
	if not FileAccess.file_exists(save_path):
		Log.error("Can't find save at %s" % ProjectSettings.globalize_path(save_path))

	var save_file := FileAccess.open(save_path, FileAccess.READ)
	var json_string = save_file.get_line()
	var json := JSON.new()

	var parse_result := json.parse(json_string)
	if not parse_result == OK:
		Log.error("JSON Parse Error: " + json.get_error_message() + " in " + json_string + " at line " + json.get_error_line())

	var room_data = json.data["room"]

	var room := (load(room_data["theme"]) as RoomTheme).create()
	if Room.current:
		Room.current.queue_free()
	Room.current = room
	room.load_save(room_data)

	Player.local_instance.load_save(json.data["player"])
	await Lib.ensure_ready(UI.instance)
	UI.instance.backpack.load_save(json.data["inventory"])

	Main.save_name = save_name
	Log.notice("Loading Save Finished")


static func save_vector2(vector: Vector2, name: String, save: Dictionary) -> void:
	save[name + "@x"] = vector.x
	save[name + "@y"] = vector.y


static func load_vector2(name: String, save: Dictionary) -> Vector2:
	var vector := Vector2()
	vector.x = save[name + "@x"]
	save.erase(name + "@x")
	vector.y = save[name + "@y"]
	save.erase(name + "@y")
	return vector


static func load_to_object(object: Object, save: Dictionary) -> void:
	for i in save:
		object.set(i, save[i])


static func load_to_node(node: Node, save: Dictionary) -> void:
	await Lib.ensure_ready(node)
	load_to_object(node, save)


static func simple_open_file(path, access_mode: FileAccess.ModeFlags) -> FileAccess:
	var file = FileAccess.open(path, access_mode)
	var error := FileAccess.get_open_error()
	if error:
		Log.error("opening file at %s failed: " % ProjectSettings.globalize_path(path) + error_string(error))
	return file


static func simple_open_dir(path) -> DirAccess:
	var dir = DirAccess.open(path)
	var error := DirAccess.get_open_error()
	if error:
		Log.error("opening directory at %s failed: " % ProjectSettings.globalize_path(path) + error_string(error))
	return dir
