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
## when set Vector2i(-1, -1), will automatically resize according to its template size
## NOTE this property use a pointing-up Y axis !
@export var size := UNDEFINED_VECTOR2i
@export var project_mode: ProjectMode  ## TODO
enum ProjectMode {
	NONE,  ## Don't project, keep where it is , see initial_y_mode
	KEEP,  ## Projected to the terrain, but keep its main structure unchanged
	TERRAIN,  ## Projected to the terrain and may change the structure to adapt to the terrain
	STRETCH,
	PLATFORM,
}
@export var project_dire := Vector2i.DOWN
@export var project_max_length := 20

@export var place_mode: PlaceMode  ## TODO
enum PlaceMode {
	PLACE,
	ERASE,
	REPLACE,
}
@export var replace_blacklist: Dictionary[StringName, int] = {&"Frame": 0}

@export_group("initial_y_position")
## This determine the initial position of the [Structure][br]
## NOTE the structure will then be projected to the terrain according to its [prop project_mode]
## or will try another possible position if projection failed
@export var initial_y_mode: InitialYMode
enum InitialYMode {
	FIXED,  ## Always spawn on a fixed height
	WEIGHTED,  ## Use [prop height_possibility_curve] to determine its initial height
	## not recommended to use with ProjectMode.STRETCH or [const ProjectMode.TERRAIN]
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


var _x_offset: Array[int] = []
var _y_offset: Array[int] = []


func spawn_template(at: Vector2i, room := Room.current):
	print(at)
	_y_offset.resize(size.x)
	_x_offset.resize(size.y)
	if project_mode == ProjectMode.TERRAIN:
		if project_dire.y:
			var y := size.y if project_dire.y < 0 else 0
			for x in size.x:
				_y_offset[x] = _project_to_terrain(at + Vector2i(x, y), room).y - y - at.y
		if project_dire.x:
			var x := size.x if project_dire.x > 0 else 0
			for y in size.y:
				_x_offset[y] = _project_to_terrain(at + Vector2i(x, y), room).x - x - at.x
	print(_x_offset, _y_offset)

	for y in template.size():
		var row = template[y]
		for x in row.size():
			if row[x]:
				var block_coord := at + Vector2i(x + _x_offset[y], y + _y_offset[x])
				place_a_blockn(block_coord, row[x], room)


# Don't be confused with Room.place_block
## place a block in room, the exact behavior is determined by property place_mode
func place_a_blockn(coord: Vector2i, block_name: StringName, room := Room.current) -> void:
	if not room.has_coord(coord):
		return
	match place_mode:
		PlaceMode.PLACE:
			var prev := room.get_block(coord)
			if not prev or not prev.config.solid:
				room.set_blockn(coord, block_name, false)
		PlaceMode.ERASE:
			room.erase_block(coord)
		PlaceMode.REPLACE:
			var prev := room.get_block(coord)
			if prev and prev.config.name in replace_blacklist:
				return
			room.set_blockn(coord, block_name)


## project a coordinate to terrain according to the [project_mode]
func project(from: Vector2i, room := Room.current) -> Vector2i:
	match project_mode:
		ProjectMode.NONE:
			return from
		ProjectMode.KEEP:
			return _project_to_terrain(from, room)
		ProjectMode.TERRAIN:
			return _project_to_terrain(from, room)
		ProjectMode.STRETCH:
			return from
	return UNDEFINED_VECTOR2i


## project a coordinate to terrain
func _project_to_terrain(from: Vector2i, room := Room.current) -> Vector2i:
	print("from",from)
	for i in TileOP.ray(from, project_dire, project_max_length, room):
		if not room.has_coord(i):
			break
		var block := room.get_block(i)
		print("\tblock:", block)

		while block and block.config.solid:  # meet barriers, go in the opposite direction
			i -= size * project_dire
			block = room.get_block_safe(i)
			if not block:
				print(i)
				return i


	return UNDEFINED_VECTOR2i


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
