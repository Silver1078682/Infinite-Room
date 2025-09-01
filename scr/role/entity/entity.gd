class_name Entity
extends CharacterBody2D
## Base Class for Entities.
## NOTE: call super() for every child class in _physics_process.

## The coordinate of the [Entity].[br]
## please make sure the position should be near the entity's feet.(where the hitbox touch the ground)
var coord: Vector2i:
	get:
		return Main.Map.to_coord(position)
	set(p_coord):
		position = Main.Map.to_pos(p_coord)

var _speed_factor_from_block: float


func _get_speed_factor() -> float:
	var block := get_floor_block()
	return block.config.speed_factor if block else 1.0

func get_floor_block() -> Block:
	if is_on_floor() and Room.current.get_block_safe(coord + Vector2i.DOWN):
		return Room.current.get_block_safe(coord + Vector2i.DOWN)
	return null

## Please set true for all moving entity
@export var record_coord_changed := true

## emiited when the coordinate of the [Entity] changed,
## requiring [prop record_coord_chenged] set true
signal coord_changed
var _last_coord: Vector2i


func _on_coord_changed():
	pass

func _physics_process(delta: float) -> void:
	if coord != _last_coord:
		_last_coord = coord
		_on_coord_changed()
		coord_changed.emit()
