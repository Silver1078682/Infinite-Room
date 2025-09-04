## A tool for creating structure intuitively
extends TileMapLayer
const STRUCTURE_SAVE_DIR_PATH = Structure.STRUCTURE_SAVE_DIR_PATH


var pre_template: Array[Array]


func update():
	var atlas_to_block: Dictionary[Vector2i, StringName] = {}
	var diraccess := SL.simple_open_dir(Block.CONFIG_DIR_PATH)
	if not diraccess:
		printerr(DirAccess.get_open_error())
		return

	for file_name in diraccess.get_files():
		var block_name := file_name.split(".")[0]
		var block: BlockConfig = load(Block.CONFIG_FILE_PATH % block_name)
		atlas_to_block[block.atlas_coord] = block_name

	var rect := get_used_rect()
	pre_template = Lib.Arr.matrix_2d(rect.size, null)

	for i: Vector2i in get_used_cells():
		var coord = i - rect.position
		if get_cell_atlas_coords(i) in atlas_to_block:
			pre_template[coord.y][coord.x] = atlas_to_block[get_cell_atlas_coords(i)]
		else:
			erase_cell(coord)



func debug_print():
	print("---template---")
	for row in pre_template:
		print(row)
	print("---ray---")
	for i in $TileMapDrawer.rays:
		print( $TileMapDrawer.rays[i])

@onready var line_edit: LineEdit = %SaveName

func save():
	var new_struct := Structure.new()
	new_struct.template = pre_template
	for i in $TileMapDrawer.rays:
		i
	print("save ", new_struct, " at ", STRUCTURE_SAVE_DIR_PATH, %SaveName.text, ".tres")
	ResourceSaver.save(new_struct, STRUCTURE_SAVE_DIR_PATH + %SaveName.text + ".tres")
