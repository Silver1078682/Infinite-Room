extends Node2D
# detect whether a block can be laid at a position
const SCENE_PATH := "res://scr/roles/entities/player/place_detect/place_detect.tscn"
const SCENE := preload(SCENE_PATH)

@onready var drop_polygon: CollisionPolygon2D = $DropDetect/CollisionPolygon2D
@onready var entity_polygon: CollisionPolygon2D = $EntityDetect/CollisionPolygon2D


func _ready() -> void:
	drop_polygon.polygon = DETECT_POLYGON
	entity_polygon.polygon = DETECT_POLYGON


func can_lay() -> bool:
	if %EntityDetect.has_overlapping_bodies():
		return false
	if %DropDetect.has_overlapping_bodies():
		return false
	return true



const DETECT_POLYGON: PackedVector2Array = [
	Vector2(-Block.SIZE.x, -Block.SIZE.x) / 2,
	Vector2(Block.SIZE.x, -Block.SIZE.x) / 2,
	Vector2(Block.SIZE.x, Block.SIZE.x) / 2,
	Vector2(-Block.SIZE.x, Block.SIZE.x) / 2,
]
