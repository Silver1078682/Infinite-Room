class_name Room
extends Node2D
## [Room] is any room that enters the world.
## each [Room] has a [RoomTheme]

# typical LifeCycle of a room
# 1. created by [RoomTheme]
# 2. spawn landscape(see [RoomTheme]) for a new room / load map if we have entered this room
# 3. added to tree via [RoomManager], see [method enter]
# 4. exit from tree, see [method exit]

## The height of all rooms
const HEIGHT = 20


static func _static_init() -> void:
	Console.add_command("place", _command_place_block, "Place a block at a given coordinate.")


static func _command_place_block(x: int, y: int, block_name: StringName):
	var coord: Vector2i = World.Map.h2gui(Vector2i(x, y))
	if not Room.current.has_coord(coord):
		Console.error("coordinate (x, y) not at map")
		return
	Room.current.place_blockn(coord, block_name)


## It serves as an alias to get the current room in [SceneTree]
## Read-only attribute
static var current: Room:
	set(p_current):
		const WARNING = "Please don't set this read-only attribute"
		const ADVICE = "call RoomManager.enter_room() instead"
		Log.warning(WARNING + ", " + ADVICE)
	get:
		return RoomManager.get_current_room()

var idx = 0
var start_time: int
var total_time_spent := 0
var theme: RoomTheme

#
var width := 20


func size() -> Vector2i:
	return Vector2i(width, HEIGHT)


## return if the [param coord] is inside room.
func has_coord(coord: Vector2i) -> bool:
	return 0 <= coord.x and coord.x < width and 0 <= coord.y and coord.y < HEIGHT


## get the block at [param coord]
func get_block(coord: Vector2i) -> Block:
	return _blocks[coord.y][coord.x]


## get the block at [param coord]. return null if the coord is outside the room
func get_block_safe(coord: Vector2i) -> Block:
	if not has_coord(coord):
		return null
	return _blocks[coord.y][coord.x]


## basic api, only use when necessary
## place the [param block] at [param coord]. will replace the previous block[br]
## update the block in World.Map if [param update] set true.
## Typically, the [param update] should be set true if the room is in SceneTree, otherwise set false
func set_block(coord: Vector2i, block: Block, update := true) -> void:
	block.coord = coord
	if update:
		World.Map.set_block(coord, block)
	_blocks[coord.y][coord.x] = block


## basic api, only use when necessary
## Same as [func set_block], use block_name to refer to a block instead.
func set_blockn(coord: Vector2i, block_name: String, update := true) -> void:
	set_block(coord, Block.create(block_name), update)


## place the [param block] at [param coord]. will replace the previous block[br]
## update the block in World.Map if [param update] set true.
## Typically, the [param update] should be set true if the room is in SceneTree, otherwise set false
func place_block(coord: Vector2i, block: Block) -> void:
	assert(has_coord(coord), "Given coordinate is not inside the room")
	for i in block.config.cling_to:
		var neighbor_block := get_block_safe(coord + i)
		if neighbor_block and neighbor_block.match_condition(block.config.cling_to[i]):
			neighbor_block.neighbor_bind[block] = coord
		else:
			return
	block.coord = coord
	World.Map.set_block(coord, block)
	if block.config.scene:
		block.node = block.config.scene.instantiate()
		block.node.position = World.Map.to_pos(coord)
		World.add_node.call_deferred(block.node)
	block.enter()
	_blocks[coord.y][coord.x] = block


## Same as [func place_block], use block_name to refer to a block instead.
func place_blockn(coord: Vector2i, block_name: String) -> void:
	place_block(coord, Block.create(block_name))


## basic api, only use when necessary
## simply erase the block from [Map], and unreference it
func erase_block(coord: Vector2i, update := true) -> void:
	if update:
		World.Map.erase_block(coord)
	_blocks[coord.y][coord.x] = null


## advanced api compared to [func erase_block], update the Map and so on
func remove_block(coord: Vector2i) -> void:
	World.Map.erase_block(coord)
	World.Map.update_block(coord)
	var block: Block = _blocks[coord.y][coord.x]
	block.notify_exit()
	_blocks[coord.y][coord.x] = null


## similar to [func remove_block], but won't raise an error when removing a non-existent block
func remove_block_safe(coord: Vector2i) -> void:
	if not get_block_safe(coord):
		return
	World.Map.erase_block(coord)
	World.Map.update_block(coord)
	var block: Block = _blocks[coord.y][coord.x]
	block.notify_exit()
	_blocks[coord.y][coord.x] = null


var _blocks: Array[Array]


func enter() -> void:
	World.add_node(self)
	if not is_inside_tree():
		await tree_entered
	start_time = Time.get_ticks_usec()
	update_map()
	update_camera()
	update_environment()
	Stats.room(theme.name).enter_counts += 1
	Log.info("Room Instance %s is added to tree" % self)


func update_time() -> void:
	var time_spent = Time.get_ticks_usec() - Room.current.start_time
	total_time_spent += time_spent


func update_map():
	World.Map.reset()
	if Room.current != self:
		Log.warning("a room instance outside the tree try to update the World.Map")
	for i in TileOP.rect(Vector2i.ZERO, size(), true, self):
		if get_block(i):
			place_block(i, get_block(i))


func update_camera():
	World.Camera.instance.set_limit_x(0, size().x)


func update_blocks_arr():
	_blocks = Lib.Arr.matrix_2d(size(), null)


func update_environment():
	var bg: Sprite2D = World.instance.get_node("Background")
	var el: CanvasModulate = World.instance.get_node("EnvironmentLight")
	bg.apply_scale(size())
	bg.modulate = theme.bg_color
	el.color = theme.world_modulate


func _exit() -> void:
	Stats.room(theme.name).stay_total_time += total_time_spent


func get_save() -> Dictionary[String, Variant]:
	var save_matrix = Lib.Arr.matrix_2d(size(), {})
	for y in HEIGHT:
		for x in width:
			var block: Block = _blocks[y][x]
			if block:
				save_matrix[y][x] = block.get_save()
	return {"width": width, "blocks": save_matrix, "theme": theme.name}


func load_save(save: Dictionary):
	width = save["width"]
	update_blocks_arr()
	update_map()
	var _block_matrix = save["blocks"]
	for y in HEIGHT:
		for x in width:
			var block = _block_matrix[y][x]
			if block:
				set_block(Vector2i(x, y), Block.load_save(block))
