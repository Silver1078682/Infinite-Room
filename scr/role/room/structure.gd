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
	Console.add_command("struct", _command_save_struct_from, "Save a structure from")


static func _command_save_struct_from(from_x: int, from_y: int) -> Structure:
	return


static func save_struct_from(from: Vector2, to: Vector2) -> Structure:
	for coord in TileOP.rect(from, to, true, null):
		pass
	return
