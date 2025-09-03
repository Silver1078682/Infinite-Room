class_name TileOPEmptyRect extends TileOPRaySet

var start: RefCounted
## editor-only
@export var _start: Vector2i:
	set(p_start):
		start = TileOP._make_coord(p_start)
		_start = p_start

var size: Vector2i

func _iter_init(iter: Array) -> bool:
	_rays.clear()
	var rect2i := Rect2i(start.coord, size)
	var room_rect := Rect2i(Vector2i.ZERO, room.size())
	rect2i = rect2i.abs()
	rect2i = rect2i.intersection(room_rect)
	_rays.append(TileOP.ray(rect2i.position, Vector2i.RIGHT, rect2i.size.x, room))
	_rays.append(TileOP.ray(rect2i.position, Vector2i.DOWN, rect2i.size.y, room))
	_rays.append(TileOP.ray(rect2i.end - Vector2i.ONE, Vector2i.LEFT, rect2i.size.x, room))
	_rays.append(TileOP.ray(rect2i.end - Vector2i.ONE, Vector2i.UP, rect2i.size.y, room))
	return super(iter)
