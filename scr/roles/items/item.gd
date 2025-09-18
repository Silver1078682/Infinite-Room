@tool
class_name Item
extends Resource
@export var name: String
@export_tool_button("update according to file name") var update_name := _update_name
@export var texture: Texture
@export var material: MATERIAL
@export var inflammable := false
@export var drop_physics: PhysicsMaterial
@export var stack_amount := 100
@export var meta: Dictionary[String, Variant] = {}
@export_group("preset")
@export_tool_button("block") var add_block = _add_block

const Drop := preload("res://scr/roles/items/drop/drop.gd")

enum MATERIAL {
	UNKNOWN,
	WOOD,
	STONE,
}


## drop an item at the given coordinate, also returns the drop
static func drop_at(coord: Vector2i, item: Item, initial_velocity := _get_random_velocity()) -> Drop:
	return drop_at_global_pos(Main.Map.to_pos(coord), item, initial_velocity)


## drop an item at the global position, also returns the drop
static func drop_at_global_pos(position: Vector2, item: Item, initial_velocity := _get_random_velocity()) -> Drop:
	var drop: Drop = Drop.SCENE.instantiate()
	drop.global_position = position
	drop.item = item
	drop.linear_velocity = initial_velocity
	Room.current.add_child.call_deferred(drop)
	return drop


## Create an item. Return null on failure
static func create(item_name: StringName) -> Item:
	if not item_name:
		return null
	var item: Item = load("res://scr/role/items/type/%s.tres" % item_name)
	if not item:
		Log.warning("try to create an non-existent Item named %s" % item_name)
		assert(false)
		return null
	return item


## return if an item exists
static func has_item(item_name: StringName) -> bool:
	return FileAccess.file_exists("res://scr/role/items/type/%s.tres" % item_name)


# add a random velocity to a new drop
static func _get_random_velocity() -> Vector2:
	var one := Vector2(randf_range(10, 20), 0)
	one = one.rotated(randf_range(0, TAU))
	return one


func _add_block():
	meta["block"] = name
	if FileAccess.file_exists(ResPath.BLOCK.file % name):
		texture = Block.create(name).config.texture


func _update_name() -> void:
	name = resource_path.split("/")[-1].split(".")[0]
