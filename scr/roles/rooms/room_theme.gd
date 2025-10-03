@tool
class_name RoomTheme
extends Resource
## RoomTheme determine how a room should be spawned and how they should look like.
# there's many details in the script, and i don't want to review them :(
# just use the api

@export_group("name")
## The name of the [RoomTheme]
@export var name: StringName
@export_tool_button("update according to file name") var update_name := _update_name

@export_group("size")
## minimum width of the [RoomTheme], including border
@export var min_width := 20
## maximum width of the [RoomTheme], including border
@export var max_width := 40
# in most cases, this should be set true(I can't think up a exception)
## whether a rectangle frame will be spawned.
@export var frame_on := true

@export_group("terrain")
## All [Terrain] in this array will be spawned in order. 
@export var terrain_layers: Array[Terrain]
# dp? list for cached terrain altitude
var _terrain_height: Array[int]

@export_group("structure")
## minimum upper limit of structure weight the room can has.[br]
## The room will greedily spawn the structure till the upper limit max_is exceeded
@export var min_structure_weights_total: int = 10

## maximum upper limit of structure weight the room can has.[br]
## see [prop min_structure_weights_total] for details
@export var max_structure_weights_total: int = 20

## ignore structure weight
## see [prop min_structure_weights_total] for details
@export var ignore_weight := false

## The list of structures that can be spawned.
@export var structures: Array[Structure] = []

@export_group("environment")
## background color of the room
@export var bg_color: Color
## a modulate of the room
@export var world_modulate: Color
## TODO
## add more environment stuffs


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
	_terrain_height.resize(room.width - 2)
	_terrain_height.fill(Room.HEIGHT + Vector2i.UP.y * 2)
	
	for layer in terrain_layers:
		layer.set_width(room.width)
		for x in room.width - 2:
			var current_height := _terrain_height[x]
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

			_terrain_height[x] = target_height


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
