extends TileMapLayer
## Map
## use built-in [TileMapLayer] to render textures and calculate terrian collision.

static var _instance: TileMapLayer


func _init() -> void:
	_instance = self


static func set_block(coord: Vector2i, block: Block) -> void:
	_instance.set_cell(coord, 0, block.config.atlas_coord, 0)
	BetterTerrain.update_terrain_cell(_instance, coord)


static func erase_block(coord: Vector2i) -> void:
	_instance.erase_cell(coord)


static func reset() -> void:
	_instance.clear()


## convert a coordinate to position
## the result will be exactly the center of the block
static func to_pos(coord: Vector2i) -> Vector2:
	return _instance.map_to_local(coord)


## convert a position to coordinate
static func to_coord(pos: Vector2) -> Vector2i:
	return _instance.local_to_map(pos)


## change a human-readble coordinate (y axis pointing up)  to a normal coordinate (y axis pointing down)
static func h2gui(coord: Vector2i) -> Vector2i:
	return Vector2i(coord.x, Room.HEIGHT - coord.y - 1)


static func update_block(coord: Vector2i) -> void:
	BetterTerrain.update_terrain_cell(_instance, coord)
