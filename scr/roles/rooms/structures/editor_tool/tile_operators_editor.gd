extends Node2D

var initial_coord: Vector2i
var adding_a_tile_op := false

@export var rays: Dictionary[Vector2i, TileOPRay] = {}
@export var rects: Dictionary[Vector2i, TileOPEmptyRect] = {}


func add_ray(from: Vector2i, to: Vector2i):
	var offset: Vector2 = to - from
	var dire = [
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
	][offset.angle() / TAU * 8]
	rays[from] = (TileOP.ray(from, dire, 10))


func add_rect(from, to):
	rects


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.is_released():
			return
		var coord: Vector2i = get_parent().local_to_map(get_local_mouse_position())

		if event.button_index == MOUSE_BUTTON_LEFT:
			if adding_a_tile_op:
				adding_a_tile_op = false
				if Input.is_key_label_pressed(KEY_SHIFT):
					add_rect(initial_coord, coord)
				else:
					add_ray(initial_coord, coord)
			elif get_parent().get_cell_tile_data(coord):
				initial_coord = coord
				adding_a_tile_op = true
				return

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			rays.erase(coord)
			rects.erase(coord)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if coord in rays:
				if event.ctrl_pressed:
					rays[coord].max_length -= 1
				if event.alt_pressed:
					rays[coord].min_length -= 1
				if not event.ctrl_pressed and event.alt_pressed:
					rays[coord].length -= 1

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if coord in rays:
				if event.ctrl_pressed:
					rays[coord].max_length += 1
				if event.alt_pressed:
					rays[coord].min_length += 1
				if not event.ctrl_pressed and event.alt_pressed:
					rays[coord].length += 1
		adding_a_tile_op = false


func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	for i in rays:
		var ray := rays[i]
		const RAY_COLOR := Color(Color.AQUA, 0.4)
		const RAY_MIN_MAX_COLOR := Color(Color.WHITE, 0.4)
		var start := Vector2(ray.start.coord) * Block.SIZE + Block.SIZE / 2
		draw_circle(start, 5, RAY_COLOR)
		draw_line(start, start + Vector2(ray.dire * ray.length) * Block.SIZE, RAY_COLOR, 5)
		
		if ray.random_length:
			var max_end := start + Vector2(ray.dire * ray.max_length) * Block.SIZE
			var min_end := start + Vector2(ray.dire * ray.min_length) * Block.SIZE
			draw_line(start, max_end, RAY_MIN_MAX_COLOR, 2)
			var direo = Vector2(ray.dire).orthogonal()
			draw_line(max_end - direo * 10, max_end + direo * 10, RAY_MIN_MAX_COLOR, 2)
			draw_line(min_end - direo * 5, min_end + direo * 5, RAY_MIN_MAX_COLOR, 2)
