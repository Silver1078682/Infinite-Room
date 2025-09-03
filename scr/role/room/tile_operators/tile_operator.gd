class_name TileOP
extends Resource
## Tile operator[br]
## Helpful tools to operate on multiple coordinates at same time.[br]
## You can use the static function to get a corresponding [TileOP]
## Use the given methods of a Operator or iterate a Operator
var room: Room


static func ray(from, dire := Vector2i.DOWN, max_length := 10, room := Room.current) -> TileOPRay:
	var ray_operator = TileOPRay.new()
	ray_operator.start = _make_coord(from)
	ray_operator.dire = dire
	ray_operator.max_length = max_length
	ray_operator.room = room
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
static func rect(position, size: Vector2i, filled := false, room := Room.current) -> TileOPRaySet:
	var rect_operator = TileOPFilledRect.new() if filled else TileOPEmptyRect.new()
	rect_operator.start = _make_coord(position)
	rect_operator.size = size
	rect_operator.room = room
	return rect_operator




func search(block_name: StringName):
	for coord: Vector2i in self:
		if not room.has_coord(coord):
			continue
		elif room.get_block(coord).config.name == block_name:
			return coord
	return Vector2i(-1, -1)


func search_all(block_name: StringName) -> Array[Vector2i]:
	var coords := []
	for coord: Vector2i in self:
		if not room.has_coord(coord):
			continue
		elif room.get_block(coord).config.name == block_name:
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


class CoordHolder extends RefCounted:
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
