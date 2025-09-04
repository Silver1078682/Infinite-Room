#@tool
class_name RoomTheme
extends Resource
@export_group("name")
@export var name: StringName
#@export_tool_button("update according to file name") var update_name := _update_name
@export_group("size")
@export var min_width := 20
@export var max_width := 40
@export var frame_on := true
@export_group("terrian")
@export var terrian_layers: Array[Terrian]
var terrian_height: Array
@export var structures: Array[Structure] = []
@export_group("environment")
@export var bg_color: Color
@export var world_modulate: Color


func create() -> Room:
	var room := Room.new()

	room.width = randi_range(min_width, max_width)
	room.update_blocks_arr()
	room.theme = self

	Log.info("Room %s start spawning" % room)
	_spawn(room)
	return room


func _spawn(room: Room):
	if frame_on:
		Log.info("Spawning Frame...")
		_spawn_frame(room)
	Log.info("Spawning terrian...")
	_spawn_terrian(room)
	Log.info("Spawning structure...")
	_spawn_structure(room)
	Log.info("Spawning finished")


func _spawn_frame(room: Room) -> void:
	var frame := TileOP.rect(Vector2i.ZERO, room.size(), false, room)
	frame.fill("Frame", false)


func _spawn_terrian(room: Room) -> void:
	terrian_height.resize(room.width - 2)
	terrian_height.fill(Room.HEIGHT + Vector2i.UP.y * 2)
	for layer in terrian_layers:
		layer.set_width(room.width)
		for x in room.width - 2:
			var target_height = Room.HEIGHT - layer.get_value(x)
			var block_type = layer.block_type
			var current_height = terrian_height[x]
			if block_type:
				TileOP.ray(Vector2i(x + 1, current_height), Vector2i.UP, current_height - target_height, room).fill(block_type, false)
			terrian_height[x] = target_height


func _spawn_structure(room: Room) -> void:
	for i: Structure in structures:
		i.auto_resize()
		var spawn_coord := i.find_place(room)
		if spawn_coord != Vector2i(-1, -1):
			if not i.spawn(spawn_coord, room):
				Log.info("A structure has failed to spawn")
			else:
				Log.info("A structure instance extending %s has been spawned at %s" % [i, spawn_coord])
		else:
			Log.info("A structure has failed to spawn, reason: No feasible position found")



func _update_name() -> void:
	name = resource_path.split("/")[-1].split(".")[0]
