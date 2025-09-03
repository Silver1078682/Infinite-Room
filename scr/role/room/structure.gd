## WIP
class_name Structure
extends Resource
@export var template: Array[Array]

@export_group("tile_operator")
## TileOPSets
## Will call in order when the [Structure] is spawned
@export var blocks: Dictionary[TileOP, Dictionary] = {}

@export_group("place_behavior")
@export var project_mode: ProjectMode  ## TODO
enum ProjectMode {
	KEEP,
	LANDSCAPE,
	STRETCH,
	PLATFORM,
}
@export var project_dire: Vector2i
@export var project_max_length: int
@export var place_mode: PlaceMode  ## TODO
enum PlaceMode {
	REPLACE,
	WHITELIST,
	BLACKLIST,
}

@export_group("initial_y_position")
## This determine the initial position of the [Structure][br]
## NOTE the structure will then be projected to the landscape according to its [prop project_mode]
## or will try another possible position if projection failed
@export var initial_y_mode: InitialYMode
enum InitialYMode {
	FIXED,  ## Always spawn on a fixed height
	WEIGHTED,  ## Use [prop height_possibility_curve] to determine its initial height
	## not recommended to use with ProjectMode.STRETCH or ProjectMode.LANDSCAPE
}

@export var initial_y := 0
# This property can be used foSTRETCHr structures like underground mine or buried remains[br]
# TBD any other potentials?
## This property only works when [prop initial_y_mode] set WEIGHTED
## curve suggesting how spawning possibility varies on altitude
## The domain and the value range should be set [0, 1]
## Higher the x, Lower the altitude
## Higher the y, Greater the altitude
@export var height_possibility_curve: Curve:
	set = set_height_possibility_curve

var _weighted_dictionary: Dictionary[int,float]
var _ares_wrs: Lib.Rand.AResWRS
@export var x_step: int = 5


## spawn the [Structure], this function does not check whether [param at] is a feasible location
## In other word, It does not guarantee success
func spawn(at: Vector2i, room := Room.current) -> bool:
	for y in template.size():
		var row = template[y]
		for x in row.size():
			room.set_blockn(Vector2i(x, y) + at, row[x], false)

	for op in blocks:
		op.start.coord += at
		op.room = room
		var dict: Dictionary[StringName, float] = {}
		dict.assign(blocks[op])
		op.fill_rand(dict)

	return true


## try find a place to spawn the structure
## return Vector2i(-1, -1) on failure
func find_place(room := Room.current) -> Vector2i:
	var offsets := range(0, x_step)
	offsets.shuffle()
	for offset in offsets:
		var xs := range(offset, room.size().x, x_step)
		xs.shuffle()
		for x in xs:
			var y: int
			match initial_y_mode:
				InitialYMode.FIXED:
					y = initial_y
				InitialYMode.WEIGHTED:
					_ares_wrs.assign(_weighted_dictionary)
					y = _ares_wrs.pop()[0]
			var coord := Vector2i(x, y)
			coord = project(coord, room)
			if can_spawn_at(coord):
				return coord
	return Vector2i(-1, -1)


## whether the [Structure] can be spawned
func can_spawn_at(coord: Vector2i) -> bool:
	return true


## project a coordinate to landscape
func project(coord: Vector2i, room := Room.current, mode := project_mode) -> Vector2i:
	match mode:
		ProjectMode.KEEP:
			return coord
		ProjectMode.LANDSCAPE:
			for i in TileOP.ray(coord, project_dire, project_max_length, room):
				if not room.has_coord(i):
					break
				var block := room.get_block(coord)
				if block and block.config.solid:
					return i - project_dire
		ProjectMode.LANDSCAPE:
			return coord
	return Vector2i(-1, -1)


func set_height_possibility_curve(p_curve: Curve) -> void:
	# generate the dictionary for weighted random sampling
	_weighted_dictionary.clear()
	if not p_curve:
		return
	for i in Room.HEIGHT:
		_weighted_dictionary[i] = p_curve.sample(i)
	height_possibility_curve = p_curve


static func _static_init() -> void:
	Console.add_command("struct", _command_add_struct_pre_area, "Add a structure prepare area")
	Console.add_command("structop", _command_struct_op, "Operates a structure prepare area")


## screenshot an area of a room, return a corresponding structure
static func screenshot(op: TileOPFilledRect, room := Room.current) -> Structure:
	var result := Structure.new()
	var name_arr: Array[String] = []
	var p_template := Lib.Arr.matrix_2d(op.size, null, name_arr)

	var start: Vector2i = Rect2i(op.start.coord, op.size).abs().position  #get the top left corner
	for global_coord: Vector2i in op:
		var coord := global_coord - start
		var block := room.get_block(global_coord)
		p_template[coord.y][coord.x] = block.config.name if block else &""

	result.template = p_template
	return result


# console command stuffs below
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

		var a:
			Console.warning("subcommand %s not found under command struct" % a)


const STRUCTURE_SAVE_DIR_PATH = "res://scr/role/room/structure/"


static func _command_struct_save(name := "") -> void:
	var structure := screenshot(_command_struct_pre_op)
	SL.save_something(STRUCTURE_SAVE_DIR_PATH, structure)
	Log.notice("Saving a struct named %s" % name)
