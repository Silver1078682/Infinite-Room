class_name TileOPFilledRect extends TileOPRaySet

var start: RefCounted
## editor-only
@export var _start: Vector2i:
	set(p_start):
		start = TileOP._make_coord(p_start)

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
