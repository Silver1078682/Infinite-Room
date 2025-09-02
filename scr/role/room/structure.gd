class_name Structure
extends Resource
@export var template := ArrLib.matrix_2d(Vector2(10, 10), null, [])
@export var project_mode: int
enum ProjectMode { KEEP, LANDSCAPE, STRETCH }


func spawn(at: Vector2, room := Room.current):
	for y in template.size():
		var row = template[y]
		for x in row.size():
			room.set_blockn(Vector2i(x, y), row[x], false)


static func _static_init() -> void:
	Console.add_command("struct", _command_add_struct_prerange, "Save a structure from")


static var _command_struct_pre_range: Rect2i


static func _command_add_struct_prerange(from_x: int, from_y: int, size_x: int, size_y: int) -> Structure:
	var from: Vector2i = Main.Map.h2gui(Vector2i(from_x, from_y))
	var size: Vector2i = Main.Map.h2gui(Vector2i(size_x, size_y))
	_command_struct_pre_range.position = from
	_command_struct_pre_range.end = size
	print(from, size)
	save_struct_from(from, size)
	return


static func save_struct_from(from: Vector2i, size: Vector2i) -> Structure:
	for coord in TileOP.rect(from, size, true, Room.current):
		print(coord)
	return
