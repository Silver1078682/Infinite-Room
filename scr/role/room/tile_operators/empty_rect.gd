class_name TileOPEmptyRect extends TileOPRaySet

var start: RefCounted
## editor-only
@export var _start: Vector2i:
	set(p_start):
		start = TileOP._make_coord(p_start)

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
