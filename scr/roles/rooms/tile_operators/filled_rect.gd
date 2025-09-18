class_name TileOPFilledRect extends TileOPRaySet

## editor-only
@export var _start: Vector2i:
	set(p_start):
		start = TileOP._make_coord(p_start)
		_start = p_start

var size: Vector2i


func _iter_init(_iter: Array) -> bool:
	_rays.clear()
	var rect2i := Rect2i(start.coord, size)
	var room_rect := Rect2i(Vector2i.ZERO, room.size())
	rect2i = rect2i.abs()
	rect2i = rect2i.intersection(room_rect)
	for i in rect2i.size.y:
		var pos = Vector2i(rect2i.position.x, rect2i.position.y + i)
		_rays.append(TileOP.ray(pos, Vector2i.RIGHT, rect2i.size.x, room))
	return super(_iter)
