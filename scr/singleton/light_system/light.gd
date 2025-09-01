## WIP
## TODO Finish this shit

extends Node
var light_map := Lib.Arr.matrix_2d(Vector2i(12, 12), 0)
var barriers := light_map.duplicate(true)
var pre_h := light_map.duplicate(true)
var pre_v := light_map.duplicate(true)
var light_h := light_map.duplicate(true)
var light_v := light_map.duplicate(true)
const AIR_REDUCTION = 1


func _ready() -> void:
	extend_light(light_map, pre_h, true)
	extend_light(light_map, pre_v, false)
	extend_light(pre_v, light_h, true)
	extend_light(light_h, light_v, true)
	for x in light_map[0].size():
		for y in light_map.size():
			light_v[y][x] = max(light_v[y][x], light_h[y][x], pre_h[y][x], pre_v[y][x], light_map[y][x])


func extend_light(read, write, h_or_v):
	var max = Vector2i(read[0].size() - 1, read.size() - 1)
	var min = Vector2i.ZERO
	var x_too_big = func(c): return c.x > max.x
	var y_too_big = func(c): return c.y > max.y
	var x_too_small = func(c): return c.x < min.x
	var y_too_small = func(c): return c.y < min.y
	if h_or_v:
		iter(read, write, min, Vector2i.RIGHT, func(c): return Vector2i(0, c.y + 1), x_too_big, y_too_big)
		iter(read, write, max, Vector2i.LEFT, func(c): return Vector2i(max.x, c.y - 1), x_too_small, y_too_small)
	else:
		iter(read, write, max, Vector2i.UP, func(c): return Vector2i(c.x - 1, max.y), y_too_small, x_too_small)
		iter(read, write, min, Vector2i.DOWN, func(c): return Vector2i(c.x + 1, 0), y_too_big, x_too_big)


func iter(read, write, start, dire, next, should_next, should_stop):
	var coord = start
	var light = 0
	while not should_stop.call(coord):
		while not should_next.call(coord):
			write[coord.y][coord.x] = max(write[coord.y][coord.x], light)
			var new_light = read[coord.y][coord.x]
			light = max(light, new_light) - barriers[coord.y][coord.x]
			light -= AIR_REDUCTION
			light = max(0, light)
			coord += dire
		light = 0
		coord = next.call(coord)


func get_rect() -> Rect2i:
	return Rect2i()
