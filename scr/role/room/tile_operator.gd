class_name TileOP
extends RefCounted
## Helpful tools to operate on a group of coords at a time
## Use the static function to get a Detector
## Use the given methods of a Detector or iterate a Detector


static func ray(from, dire := Vector2i.DOWN, max_length := 10, room := Room.current) -> Ray:
	var ray_detector = Ray.new()
	ray_detector.start = _make_coord(from)
	ray_detector.dire = dire
	ray_detector.max_length = max_length
	ray_detector.room = room
	return ray_detector


static func rect(position, size: Vector2i, filled := false, room := Room.current) -> RaySet:
	var rect_detector = FilledRect.new() if filled else EmptyRect.new()
	rect_detector.start = _make_coord(position)
	rect_detector.size = size
	rect_detector.room = room
	return rect_detector


# accept a Vector2i or an object with property "coord"
# return a CoordHolder if a Vector2i is passed
# The point is: we can always access a Vector2i by result.coord
static func _make_coord(from) -> Object:
	var result = from
	if from is Vector2i:
		result = Detector.CoordHolder.new()
		result.coord = from
	else:
		assert(from.has_property("coord"))
	return result


class Detector:
	var room: Room

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
			if not room.has_coord(coord):
				continue
			room.set_blockn(coord, block_name, update)

	func fill_rand(blocks: Dictionary[StringName, float], update := true) -> void:
		var rand_picker := Lib.Rand.bs_wrs(blocks)
		for coord: Vector2i in self:
			if not room.has_coord(coord):
				continue
			room.set_blockn(coord, rand_picker.pick(), update)

	func erase() -> void:
		for coord: Vector2i in self:
			if not room.has_coord(coord):
				continue
			room.erase_block(coord)
			
	
	func _iter_init(_iter: Array) -> bool:
		return false

	func _iter_next(_iter: Array) -> bool:
		return false

	func _iter_get(_iter: Variant) -> Variant:
		return 

	## coordholder is simply an object with a property coord.
	class CoordHolder:
		var coord: Vector2i


class Ray:
	extends Detector
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
	extends Detector
	var _rays: Array[Ray]
	var current_ray: int

	func _iter_init(_iter: Array) -> bool:
		current_ray = 0
		return not _rays.is_empty()

	func _iter_get(_iter: Variant) -> Variant:
		return _rays[current_ray].get_value()

	func _iter_next(_iter: Array) -> bool:
		_rays[current_ray].current += 1
		if _rays[current_ray].current > _rays[current_ray].max_length:
			current_ray += 1
			if current_ray >= _rays.size():
				return false
		return true


#
#
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
		_rays.append(TileOP.ray(rect.end, Vector2i.LEFT, rect.size.x, room))
		_rays.append(TileOP.ray(rect.end, Vector2i.UP, rect.size.y, room))
		return super(iter)
