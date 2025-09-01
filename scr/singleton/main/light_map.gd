extends TileMapLayer
# Heavy calculation, consider further optimization or(and) move it to C#.
#inspired by terrraria.

## The area range where light will be calculated
const RENDER_QUAD_RANGE = Vector2i(20, 20)
const AIR_DECAY = -1
# The maximum of possible lightlevel in a tile
const MAX_LIGHT = 63
const MIN_LIGHT = 5
const ATLAS := Vector2i.ZERO


func _ready() -> void:
	_auto_create_tiles()


var _update_cnt = 0
## For every [UPDATE_LOOP], update the light
const UPDATE_LOOP = 3


func _process(_delta: float) -> void:
	if not Room.current:
		return
	_update_cnt += 1
	if _update_cnt >= UPDATE_LOOP:
		clear()
		update_render_range()
		_iter(range_top_left, Vector2i.DOWN, Vector2i.RIGHT)  #vertical_light
		_iter(range_top_left, Vector2i.RIGHT, Vector2i.DOWN, 0, false)  #horizontal_light
		_update_cnt = 0
	pass


func _auto_create_tiles() -> void:
	var atlas_source: TileSetAtlasSource = tile_set.get_source(0)
	for i in range(1, MAX_LIGHT + 1):
		atlas_source.create_alternative_tile(ATLAS, i)
		atlas_source.get_tile_data(ATLAS, i).modulate = Color(Color.WHITE, 1 - i / float(MAX_LIGHT + 1))
	notify_runtime_tile_data_update()


func get_light_info_at(coord: Vector2i) -> Array[int]:
	var block := Room.current.get_block_safe(coord)
	if block:
		return [block.config.light_decay, block.config.light_level]
	else:
		return [AIR_DECAY, 0]


func set_light_at(coord: Vector2i, light: int) -> void:
	set_cell(coord, 0, ATLAS, light)


var range_bottom_right: Vector2i
var range_top_left: Vector2i


func update_render_range() -> void:
	var camera_coord := Main.Camera.instance.coord
	range_bottom_right = Room.current.size().min(camera_coord + RENDER_QUAD_RANGE) - Vector2i.ONE 
	range_top_left = Vector2i.ZERO.max(camera_coord - RENDER_QUAD_RANGE)


func is_in_render_range(coord: Vector2i) -> bool:
	return coord.clamp(range_top_left, range_bottom_right) == coord


func _iter(from: Vector2i, dire: Vector2i, next_line: Vector2i, start_light := MAX_LIGHT, cast_light := true):
	var current := from
	while is_in_render_range(current):
		var line_end = _iter_a_line(current, dire, start_light, cast_light) - dire
		_iter_a_line(line_end, -dire)
		current += next_line


func _iter_a_line(from: Vector2i, dire: Vector2i, start_light := 0, cast_light := false) -> Vector2i:
	var light = start_light
	var current := from
	var has_met_any_barrier = not cast_light
	while is_in_render_range(current):
		if has_met_any_barrier:
			light = go_through_tile(light, current)
		else:
			light = max(start_light, get_cell_alternative_tile(current))
			if Room.current.get_block(current):
				has_met_any_barrier = true
		set_light_at(current, light)
		current += dire
	return current


func go_through_tile(previous_light: int, tile_coord: Vector2i) -> int:
	var light_info := get_light_info_at(tile_coord)
	var light_decay = light_info[0]
	var new_light = light_info[1]
	var light = max(previous_light, new_light, get_cell_alternative_tile(tile_coord)) + light_decay
	return max(MIN_LIGHT, light)
