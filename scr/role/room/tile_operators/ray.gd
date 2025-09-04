class_name TileOPRay extends TileOP

var start: RefCounted
## editor-only
@export var _start: Vector2i:
	set(p_start):
		start = TileOP._make_coord(p_start)
		_start = p_start

@export var dire: Vector2i

@export var max_length := 10:
	set(p_max_length):
		max_length = max(p_max_length, 0)
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


func _to_string() -> String:
	return "Ray[@%s, >%s, ==%s]"%[start.coord, dire, max_length]
