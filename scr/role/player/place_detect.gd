extends Node2D
const SCENE_PATH := "res://scr/role/player/place_detect.tscn"
const SCENE := preload(SCENE_PATH)

@onready var drop_polygon: CollisionPolygon2D = $DropDetect/CollisionPolygon2D
@onready var entity_polygon: CollisionPolygon2D = $EntityDetect/CollisionPolygon2D


func _ready() -> void:
	drop_polygon.polygon = normal
	entity_polygon.polygon = normal


func can_lay() -> bool:
	if %EntityDetect.has_overlapping_bodies():
		return false
	if %DropDetect.has_overlapping_bodies():
		return false
	return true


const normal: PackedVector2Array = [
	Vector2i(-Block.SIZE.x, -Block.SIZE.x) / 2,
	Vector2i(Block.SIZE.x, -Block.SIZE.x) / 2,
	Vector2i(Block.SIZE.x, Block.SIZE.x) / 2,
	Vector2i(-Block.SIZE.x, Block.SIZE.x) / 2,
]
