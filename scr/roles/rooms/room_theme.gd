@tool
class_name RoomTheme
extends Resource
## RoomTheme determine how a room should be spawned and how they should look like.


@export_group("name")
@export var name: StringName
@export_tool_button("update according to file name") var update_name := _update_name

@export_group("size")
@export var min_width := 20
@export var max_width := 40
@export var frame_on := true

@export_group("terrain")
@export var terrain_layers: Array[Terrain]
var terrain_height: Array[int]

@export_group("structure")
@export var min_structure_weights_total: int = 10
@export var max_structure_weights_total: int = 20
@export var ignore_weight := false
@export var structures: Array[Structure] = []

@export_group("environment")
@export var bg_color: Color
@export var world_modulate: Color



func spawn(room: Room) -> void:
	_spawn(room)


func _spawn(room: Room):
	Log.info("Room %s start spawning" % room)
	Log.info("Spawning terrain...")
	_spawn_terrain(room)
	Log.info("Spawning structure...")
	_spawn_structures(room)
	Log.info("Spawning finished")
	if frame_on:
		Log.info("Spawning frame...")
		_spawn_frame(room)


func _spawn_frame(room: Room) -> void:
	var frame := TileOP.rect(Vector2i.ZERO, room.size(), false, room)
	frame.fill("Frame", false)


func _spawn_terrain(room: Room) -> void:
	terrain_height.resize(room.width - 2)
	terrain_height.fill(Room.HEIGHT + Vector2i.UP.y * 2)
	for layer in terrain_layers:
		layer.set_width(room.width)
		for x in room.width - 2:
			var current_height := terrain_height[x]
			var target_height: int
			if layer.layer_mode == Terrain.Mode.ALTITUDE:
				target_height = Room.HEIGHT - layer.get_value(x)
			else:
				target_height = current_height + layer.get_value(x)

			var ray := TileOP.ray(Vector2i(x + 1, current_height), Vector2i.UP, current_height - target_height, room)
			if layer.block_weight_list:
				ray.fill_rand(layer.block_weight_list, false)
			elif layer.block_type:
				ray.fill(layer.block_type, false)

			terrain_height[x] = target_height


func _spawn_structures(room: Room) -> void:
	if ignore_weight:
		for i: Structure in structures:
			_spawn_a_structure(i, room)
	else:
		var total = randi_range(min_structure_weights_total, max_structure_weights_total)
		var x := 0
		while x < total:
			var struct: Structure = structures.pick_random()
			x += struct.spawn_weight
			_spawn_a_structure(struct, room)


func _spawn_a_structure(structure: Structure, room: Room):
	structure.preprocess()
	var spawn_coord := structure.find_place(room)
	if spawn_coord != Vector2i(-1, -1):
		if not structure.spawn(spawn_coord, room):
			Log.info("A structure has failed to spawn")
		else:
			Log.info("A structure instance extending %s has been spawned at %s" % [structure, spawn_coord])
	else:
		Log.info("A structure has failed to spawn, reason: No feasible position found")


func _update_name() -> void:
	name = resource_path.split("/")[-1].split(".")[0]
