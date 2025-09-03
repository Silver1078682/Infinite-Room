class_name TileOP
extends Resource
## Tile operator[br]
## Helpful tools to operate on multiple coordinates at same time.[br]
## You can use the static function to get a corresponding [TileOP]
## Use the given methods of a Operator or iterate a Operator
var room: Room


static func ray(from, dire := Vector2i.DOWN, max_length := 10, room := Room.current) -> Ray:
	var ray_operator = Ray.new()
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
static func rect(position, size: Vector2i, filled := false, room := Room.current) -> RaySet:
	var rect_operator = FilledRect.new() if filled else EmptyRect.new()
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


class CoordHolder:
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

class Ray:
	extends TileOP
	var dire: Vector2i
	var start: Object
	var max_length: int
	var current := 0

	func _iter_init(_iter: Array) -> bool:
		current = 0
		return max_length != 0

	func _iter_next(_iter: Array) -> bool:
		current += 1
		return current < max_length

	func _iter_get(_iter: Variant) -> Variant:
		return get_value()

	func get_value() -> Vector2i:
		return start.coord + dire * current


class RaySet:
	extends TileOP
	var _rays: Array[Ray]
	var current_ray: int

	func _iter_init(_iter: Array) -> bool:
		current_ray = 0
		return not _rays.is_empty()

	func _iter_get(_iter: Variant) -> Variant:
		return _rays[current_ray].get_value()

	func _iter_next(_iter: Array) -> bool:
		_rays[current_ray].current += 1
		while _rays[current_ray].current >= _rays[current_ray].max_length:
			current_ray += 1
			if current_ray >= _rays.size():
				return false
		return true



class FilledRect:
	extends RaySet
	var start: Object
	var size: Vector2i

	func _iter_init(_iter: Array) -> bool:
		_rays.clear()
		var rect := Rect2i(start.coord, size)
		var room_rect := Rect2i(Vector2i.ZERO, room.size())
		rect = rect.abs()
		rect = rect.intersection(room_rect)
		for i in rect.size.y:
			var pos = Vector2i(rect.position.x, rect.position.y + i)
			_rays.append(TileOP.ray(pos, Vector2i.RIGHT, rect.size.x, room))
		return super(_iter)


class EmptyRect:
	extends RaySet
	var start: Object
	var size: Vector2i

	func _iter_init(iter: Array) -> bool:
		_rays.clear()
		var rect := Rect2i(start.coord, size)
		var room_rect := Rect2i(Vector2i.ZERO, room.size())
		rect = rect.abs()
		rect = rect.intersection(room_rect)
		_rays.append(TileOP.ray(rect.position, Vector2i.RIGHT, rect.size.x, room))
		_rays.append(TileOP.ray(rect.position, Vector2i.DOWN, rect.size.y, room))
		_rays.append(TileOP.ray(rect.end - Vector2i.ONE, Vector2i.LEFT, rect.size.x, room))
		_rays.append(TileOP.ray(rect.end - Vector2i.ONE, Vector2i.UP, rect.size.y, room))
		return super(iter)
