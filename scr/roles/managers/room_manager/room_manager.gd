class_name RoomManager
extends Node
## Create room, TODO (assign them with identifiers), add them to the world.

# the current room the [Player] is in.
static var _current_room: Room


## Avoid using this function, use [prop Room.current] instead.
static func get_current_room() -> Room:
	return _current_room if is_instance_valid(_current_room) else null


## Enter a room and exit the current one.
static func enter_room(room: Room) -> void:
	if _current_room:
		_current_room.exit()
	if room:
		room.enter()
		_current_room = room
	else:
		Log.error("Try entering a room, but the room is null instance")


## create a room with the given [RoomTheme].
## If [para should_spawn] set false, return an empty room with no blocks and no size.
static func create_a_room(theme_name: String, should_spawn := true) -> Room:
	var theme_path: String = ResPath.ROOM_THEME.file % theme_name
	var theme := load(theme_path)
	var room := Room.new()
	room.theme = theme

	if not theme:
		Log.warning("try to create an non-existent BlockConfig named %s" % theme_name)
		assert(theme)
		return null

	if should_spawn:
		room.width = randi_range(theme.min_width, theme.max_width)
		room.update_blocks_arr()
		theme.spawn(room)

	return room


@export var room_list = {}


static func predict_next_theme() -> String:
	return ""
