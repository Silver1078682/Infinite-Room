class_name TileOP
extends Resource
## Tile operator[br]
## Helpful tools to operate on multiple coordinates at same time.[br]
## You can use the static function to get a corresponding [TileOP]
## Use the given methods of a Operator or iterate a Operator
var room: Room


## Returns a ray with a fixed size
static func ray(from, dire := Vector2i.DOWN, length := 10, target_room := Room.current) -> TileOPRay:
	var ray_operator = TileOPRay.new()
	ray_operator.start = _make_coord(from)
	ray_operator.dire = dire
	ray_operator.length = length
	ray_operator.room = target_room
	return ray_operator


## WARNING the rect here act slightly different from Godot Rect2i class.[br]
## Namely, rect/Rect2i with size Vector2i(3, 4) looks like
## [codeblock]
## # rect(TileOP)  Rect2i
## #    0 1 2     0 1 2 3
## #  0 * * *   0 S - - -
## #  1 * * *   1 |     |
## #  2 * * *   2 |     |
## #  3 * * *   3 |     |
## #            4 | - - E
## [/codeblock]
static func rect(position, size: Vector2i, filled := false, target_room := Room.current) -> TileOPRaySet:
	var rect_operator = TileOPFilledRect.new() if filled else TileOPEmptyRect.new()
	rect_operator.start = _make_coord(position)
	rect_operator.size = size
	rect_operator.room = target_room
	return rect_operator


## Returns the first block with block_name
func search(block_name: StringName):
	for coord: Vector2i in self:
		var block := room.get_block_safe(coord)
		if not block:
			continue
		elif block.config.name == block_name:
			return coord
	return Vector2i(-1, -1)


## Returns all blocks with block_name in an array
func search_all(block_name: StringName) -> Array[Vector2i]:
	var coords := []
	for coord: Vector2i in self:
		var block := room.get_block_safe(coord)
		if not block:
			continue
		elif block.config.name == block_name:
			coords.append(coord)
	return coords


func fill(block_name: StringName, update := true) -> void:
	for coord: Vector2i in self:
		if room.has_coord(coord):
			room.set_blockn(coord, block_name, update)


func fill_rand(blocks: Dictionary[StringName, float], update := true) -> void:
	var rand_picker := Lib.Rand.bs_wrs(blocks)
	for coord: Vector2i in self:
		if room.has_coord(coord):
			room.set_blockn(coord, rand_picker.pick(), update)


## See [method Room.erase]
func erase() -> void:
	for coord: Vector2i in self:
		if room.has_coord(coord):
			room.erase_block(coord)


## See [method Room.remove_block]
func remove() -> void:
	for coord: Vector2i in self:
		if room.has_coord(coord):
			room.remove_block(coord)


## See [method Room.remove_block_safe]
func remove_safe() -> void:
	for coord: Vector2i in self:
		if not room.has_coord(coord):
			continue
		room.remove_block_safe(coord)


## Call a function on each block in the operators scope
func call_each(func_name: StringName) -> void:
	for coord: Vector2i in self:
		var block := room.get_block_safe(coord)
		if not block:
			continue
		block.call(func_name)


func _iter_init(_iter: Array) -> bool:
	return false


func _iter_next(_iter: Array) -> bool:
	return false


func _iter_get(_iter: Variant) -> Variant:
	return

	## coordholder is simply an object with a property coord.


class CoordHolder:
	extends RefCounted
	var coord: Vector2i


# accept a Vector2i or an object with property "coord"
# return a CoordHolder if a Vector2i is passed
# The point is: we can always access a Vector2i by using interface result.coord
static func _make_coord(from) -> Object:
	var result = from
	if from is Vector2i:
		result = TileOP.CoordHolder.new()
		result.coord = from
	else:
		assert(from.has_property("coord"))
	return result


static func _static_init() -> void:
	Console.add_command("struct", _command_add_struct_pre_area, "Add a structure prepare area")
	Console.add_command("structop", _command_struct_op, "Operates a structure prepare area")


static var _command_struct_pre_op: TileOPFilledRect
static var _command_pre_area_display: ColorRect
const _COMMAND_PRE_RANGE_COLOR := Color(Color.CORAL, 0.2)


static func _command_add_struct_pre_area(from_x: int, from_y: int, size_x: int, size_y: int) -> void:
	var from: Vector2i = Main.Map.h2gui(Vector2i(from_x, from_y))
	var size: Vector2i = Vector2i(size_x, -size_y)
	_command_struct_pre_op = TileOP.rect(from, size, true, Room.current)

	if not is_instance_valid(_command_pre_area_display):
		_command_pre_area_display = ColorRect.new()
		_command_pre_area_display.color = _COMMAND_PRE_RANGE_COLOR
		_command_pre_area_display.size = Block.SIZE
		Main.instance.add_child.call_deferred(_command_pre_area_display)

	_command_pre_area_display.position = Main.Map.to_pos(from) - Block.SIZE / 2
	_command_pre_area_display.scale = size
	return


static func _command_struct_op(operator_name := "save", parameter := "") -> void:
	assert(Room.current, "the command must operate on Room.current")
	if not _command_struct_pre_op:
		Console.warning('No existing prepare area, use "struct" command to create one')
		return
	match operator_name:
		"save":
			if not OS.is_debug_build():
				Console.warning("save command is only available in debug mode")
				return
			_command_struct_save(parameter)

		"clear":
			_command_struct_pre_op.remove_block_safe()

		"mine":
			_command_struct_pre_op.call_each("instant_break")

		"cancel":
			_command_struct_pre_op = null
			_command_pre_area_display.hide()

		_:
			Console.print("subcommands available: save clear mine cancel")


const STRUCTURE_SAVE_DIR_PATH = "res://scr/role/room/structure/"


static func _command_struct_save(name := "") -> void:
	var structure := Structure.screenshot(_command_struct_pre_op)
	SL.save_something(STRUCTURE_SAVE_DIR_PATH, structure)
	Log.notice("Saving a struct named %s" % name)
