extends TileMapLayer
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


static func to_pos(coord: Vector2i) -> Vector2:
	return _instance.map_to_local(coord)


static func to_coord(pos: Vector2) -> Vector2i:
	return _instance.local_to_map(pos)

static func update_block(coord: Vector2i) -> void:
	BetterTerrain.update_terrain_cell(_instance, coord)
