class_name Room
extends Node2D
const HEIGHT = 20


static func _static_init() -> void:
	Console.add_command("place", _command_place_block, "Place a block at a given coordinate.")


static func _command_place_block(x: int, y: int, block_name: StringName):
	var coord: Vector2i = Main.Map.h2gui(Vector2i(x, y))
	if not Room.current.has_coord(coord):
		Console.error("coordinate (x, y) not at map")
		return
	Room.current.place_blockn(coord, block_name)


# Don't set this property, use Main.enter_room instead
static var current: Room:
	set(p_current):
		if current:
			current._exit()
		if p_current:
			p_current._enter()
		current = p_current

var idx = 0
var start_time: int
var total_time_spent := 0
@export var theme := RoomTheme.new()

#
var width := 20


func size() -> Vector2i:
	return Vector2i(width, HEIGHT)


#
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


## basic api, only use when neccessary
## place the [param block] at [param coord]. will replace the previous block[br]
## update the block in Main.Map if [param update] set true.
## Typically, the [param update] should be set true if the room is in SceneTree, otherwise set false
func set_block(coord: Vector2i, block: Block, update := true) -> void:
	block.coord = coord
	if update:
		Main.Map.set_block(coord, block)
	_blocks[coord.y][coord.x] = block


## basic api, only use when neccessary
## Same as [func set_block], use block_name to refer to a block instead.
func set_blockn(coord: Vector2i, block_name: String, update := true) -> void:
	set_block(coord, Block.create(block_name), update)


## place the [param block] at [param coord]. will replace the previous block[br]
## update the block in Main.Map if [param update] set true.
## Typically, the [param update] should be set true if the room is in SceneTree, otherwise set false
func place_block(coord: Vector2i, block: Block) -> void:
	for i in block.config.cling_to:
		var neighbour_block := get_block_safe(coord + i)
		if neighbour_block and neighbour_block.match_condition(block.config.cling_to[i]):
			neighbour_block.neighbour_bind[block] = coord
		else:
			return
	block.coord = coord
	Main.Map.set_block(coord, block)
	block.enter()
	_blocks[coord.y][coord.x] = block


## Same as [func place_block], use block_name to refer to a block instead.
func place_blockn(coord: Vector2i, block_name: String) -> void:
	place_block(coord, Block.create(block_name))


## basic api, only use when neccessary
## simply erase the block from [Map], and unreference it
func erase_block(coord: Vector2i, update := true) -> void:
	if update:
		Main.Map.erase_block(coord)
	_blocks[coord.y][coord.x] = null


## advanced api compared to [func erase_block], update the Map and so on
func remove_block(coord: Vector2i) -> void:
	Main.Map.erase_block(coord)
	Main.Map.update_block(coord)
	var block: Block = _blocks[coord.y][coord.x]
	block.notify_exit()
	_blocks[coord.y][coord.x] = null

## similar to [func remove_block], but won't raise an error when removing a non-existent block
func remove_block_safe(coord: Vector2i) -> void:
	if not get_block_safe(coord):
		return
	Main.Map.erase_block(coord)
	Main.Map.update_block(coord)
	var block: Block = _blocks[coord.y][coord.x]
	block.notify_exit()
	_blocks[coord.y][coord.x] = null

var _blocks: Array[Array]


#LifeCycle
func _enter() -> void:
	Main.instance.add_child(self)
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
	Main.Map.reset()
	if Room.current != self:
		Log.warning("a room instance outside the tree try to update the Main.Map")
	for i in TileOP.rect(Vector2i.ZERO, size(), true, self):
		if get_block(i):
			place_block(i, get_block(i))


func update_camera():
	Main.Camera.instance.set_limit_x(0, size().x)


func update_blocks_arr():
	_blocks = Lib.Arr.matrix_2d(size(), null)


func update_environment():
	var bg: Sprite2D = Main.instance.get_node("Background")
	var el: CanvasModulate = Main.instance.get_node("EnvironmentLight")
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
	return {"width": width, "blocks": save_matrix, "theme": theme.resource_path}


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
