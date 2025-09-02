class_name Structure
extends Resource
@export var template := ArrLib.matrix_2d(Vector2(10, 10), null, [])
@export var project_mode: ProjectMode
enum ProjectMode { KEEP, LANDSCAPE, STRETCH }
@export var place_mode: PlaceMode
enum PlaceMode { REPLACE, WHITELIST, BLACKLIST }


func spawn(at: Vector2, room := Room.current):
	for y in template.size():
		var row = template[y]
		for x in row.size():
			room.set_blockn(Vector2i(x, y), row[x], false)


static func _static_init() -> void:
	Console.add_command("struct", _command_add_struct_pre_area, "Add a structure prepare area")
	Console.add_command("structop", _command_struct_op, "Operates a structure prepare area")


## screenshot an area of a room, return a corresponding structure
static func screenshot(op: TileOP.FilledRect, room := Room.current) -> Structure:
	var result: Structure
	var name_arr: Array[String] = []
	var template := Lib.Arr.matrix_2d(op.size, null, name_arr)

	var start: Vector2i = Rect2i(op.start.coord, op.size).abs().position  #get the top left corner
	for global_coord: Vector2i in op:
		var coord := global_coord - start
		var block := room.get_block(global_coord)

		template[coord.y][coord.x] = block.config.name if block else ""

	result.template = template
	return result


# console command stuffs below
static var _command_struct_pre_op: TileOP.FilledRect
static var _command_pre_area_display := ColorRect.new()
const _COMMAND_PRERANGE_COLOR := Color(Color.CORAL, 0.2)


static func _command_add_struct_pre_area(from_x: int, from_y: int, size_x: int, size_y: int) -> void:
	var from: Vector2i = Main.Map.h2gui(Vector2i(from_x, from_y))
	var size: Vector2i = Vector2i(size_x, -size_y)
	_command_struct_pre_op = TileOP.rect(from, size, true, Room.current)

	if not _command_pre_area_display.is_node_ready():
		_command_pre_area_display.color = _COMMAND_PRERANGE_COLOR
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

		var a:
			Console.warning("subcommand %s not found under command struct" % a)


const STRUCTURE_SAVE_DIR_PATH = "res://scr/role/room/structure/"


static func _command_struct_save(name := "") -> void:
	var structure := screenshot(_command_struct_pre_op)
	SL.save_something(STRUCTURE_SAVE_DIR_PATH, structure)
	Log.notice("Saving a struct named %s" % name)
