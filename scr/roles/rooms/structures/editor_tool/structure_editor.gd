## A tool for creating structure intuitively
extends TileMapLayer
const STRUCTURE_SAVE_DIR_PATH = TileOP.STRUCTURE_SAVE_DIR_PATH

var pre_template: Array[Array]


func _ready() -> void:
	$CanvasLayer.show()


func update():
	var atlas_to_block: Dictionary[Vector2i, StringName] = {}
	var diraccess := SL.simple_open_dir(ResPath.BLOCK.dir)
	if not diraccess:
		printerr(DirAccess.get_open_error())
		return

	for file_name in diraccess.get_files():
		var block_name := file_name.split(".")[0]
		var block: BlockConfig = load(ResPath.BLOCK.file % block_name)
		atlas_to_block[block.atlas_coord] = block_name

	var rect := get_used_rect()
	pre_template = Lib.Arr.matrix_2d(rect.size, &"")

	for i: Vector2i in get_used_cells():
		var coord = i - rect.position
		if get_cell_atlas_coords(i) in atlas_to_block:
			pre_template[coord.y][coord.x] = atlas_to_block[get_cell_atlas_coords(i)]
		else:
			erase_cell(coord)


func debug_print():
	print("\nDebugPrint!")
	print("---template---")
	for row in pre_template:
		print(row)
	print("---ray---")
	for i in $TileMapDrawer.rays:
		print($TileMapDrawer.rays[i])


@onready var line_edit: LineEdit = %SaveName
var _struct: Structure


func save():
	if not _struct:
		_struct = Structure.new()
	_struct.template = pre_template
	for i in $TileMapDrawer.rays:
		i
	print("save ", _struct, " at ", STRUCTURE_SAVE_DIR_PATH, %SaveName.text, ".tres")
	ResourceSaver.save(_struct, STRUCTURE_SAVE_DIR_PATH + %SaveName.text + ".tres")


func load_from():
	var new_struct: Structure = load(STRUCTURE_SAVE_DIR_PATH + %SaveName.text + ".tres")
	if not new_struct:
		return
	_struct = new_struct
	if %UpdateTemplateOnLoad.button_pressed:
		clear()
		pre_template = new_struct.template
		for y in pre_template.size():
			for x in pre_template[0].size():
				var block_name: StringName = pre_template[y][x]
				if not block_name:
					continue
				var block := Block.create(block_name)
				if not block:
					continue
				set_cell(Vector2i(x, y), 0, block.config.atlas_coord, 0)
	print("load from ", STRUCTURE_SAVE_DIR_PATH, %SaveName.text, ".tres")
