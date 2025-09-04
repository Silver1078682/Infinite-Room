## WIP
class_name Structure
extends Resource
@export var template: Array[Array]

@export_group("tile_operator")
## TileOPSets
## Will call in order when the [Structure] is spawned
@export var blocks: Dictionary[TileOP, Dictionary] = {}

@export_group("place_behavior")
## the size of a structure,
## when set Vector2i(-1, -1), will autoresize according to its template size
@export var size := UNDEFINED_VECTOR2i
@export var project_mode: ProjectMode  ## TODO
enum ProjectMode {
	NONE,
	KEEP,
	LANDSCAPE,
	STRETCH,
	PLATFORM,
}
@export var project_dire := Vector2i.DOWN
@export var project_max_length := 20
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

@export var initial_y := 1
# This property can be used for structures like underground mine or buried remains[br]
# TBD any other potentials?
## This property only works when [prop initial_y_mode] set WEIGHTED
## curve suggesting how spawning possibility varies on altitude
## The domain and the value range should be set [0, 1]
## Higher the x, Lower the altitude
## Higher the y, Greater the altitude
@export var height_possibility_curve: Curve:
	set = set_height_possibility_curve

var _weighted_dictionary: Dictionary[int,float]
var _ares_wrs := Lib.Rand.AResWRS.new()
@export var x_step: int = 5

const UNDEFINED_VECTOR2i := Vector2i(-1, -1)


func auto_resize() -> void:
	if size == UNDEFINED_VECTOR2i:
		if template:
			size = Vector2i(template.size(), template[0].size())
		else:
			size = Vector2i.ZERO


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
			if can_spawn_at(coord, room):
				return coord
	return UNDEFINED_VECTOR2i


## whether the [Structure] can be spawned
func can_spawn_at(coord: Vector2i, room := Room.current) -> bool:
	if not room.has_coord(coord):
		return false
	return true


## spawn the [Structure], this function does not check whether [param at] is a feasible location
## In other word, It does not guarantee success
func spawn(at: Vector2i, room := Room.current) -> bool:
	if template:
		spawn_template(at, room)

	for op in blocks:
		op.start.coord += at
		op.room = room
		var dict: Dictionary[StringName, float] = {}
		dict.assign(blocks[op])
		op.fill_rand(dict)

	return true


func spawn_template(at: Vector2i, room := Room.current):
	var last_row = template[-1]
	for y in template.size():
		var row = template[y]
		for x in row.size():
			if row[x]:
				room.set_blockn(at + Vector2i(x, y), row[x], false)


## project a coordinate to landscape
func project(from: Vector2i, room := Room.current, mode := project_mode) -> Vector2i:
	print(size)
	match mode:
		ProjectMode.NONE:
			return from
		ProjectMode.KEEP:
			return _project_down(from, room)
		ProjectMode.LANDSCAPE:
			return _project_down(from, room)
		ProjectMode.STRETCH:
			return from
	return UNDEFINED_VECTOR2i

func _project_down(from: Vector2i, room := Room.current):
	for i in TileOP.ray(from, project_dire, project_max_length, room):
		if not room.has_coord(i):
			break
		var block := room.get_block(i)
		print("\tblock:", block)
		if block and block.config.solid:
			return i - size * project_dire

func set_height_possibility_curve(p_curve: Curve) -> void:
	# generate the dictionary for weighted random sampling
	_weighted_dictionary.clear()
	if not p_curve:
		return
	for i in Room.HEIGHT:
		_weighted_dictionary[i] = p_curve.sample(i)
	height_possibility_curve = p_curve




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
