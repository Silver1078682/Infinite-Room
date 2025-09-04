class_name TileOPRay extends TileOP


## editor-only
@export var _start: Vector2i:
	set(p_start):
		start = TileOP._make_coord(p_start)
		_start = p_start

@export var dire: Vector2i

## this property take no effect if random_length set true
@export var length := max_length

@export_group("random_length")
@export var random_length := false
## this two properties take no effect if random_length set false
@export var min_length := 5:
	set(p_min_length):
		min_length = max(p_min_length, 0)
		min_length = p_min_length
		length = clamp(length, p_min_length, max_length)

@export var max_length := 10:
	set(p_max_length):
		max_length = max(p_max_length, 0)
		max_length = p_max_length
		length = clamp(length, min_length, p_max_length)
var current := 0


func _iter_init(_iter: Array) -> bool:
	current = 0
	if random_length:
		length = randi_range(min_length, max_length)
	return length != 0


func _iter_next(_iter: Array) -> bool:
	current += 1
	return current < length


func _iter_get(_iter: Variant) -> Variant:
	return get_value()


func get_value() -> Vector2i:
	return start.coord + dire * current


func _to_string() -> String:
	return "Ray[@%s, >%s, ==%s]" % [start.coord, dire, length]
