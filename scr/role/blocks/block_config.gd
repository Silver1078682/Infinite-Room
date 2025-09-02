@tool
class_name BlockConfig
extends Resource
## The config of the block, storing basic infomation

## the identifier of the block
@export var name: StringName
@export_tool_button("update according to file name") var update_name := _update_name
## see [const Block.TILE_SET]
@export_storage var atlas_coord: Vector2i

@export_group("property")
@export_subgroup("mine")
## hardness of the block
@export var hardness: float = 1.0
## how fast the block recover to its default hardness
@export var recovery: float = 0.1
@export var blast_resistance: float
@export_subgroup("factor")
## How much entity can speed up on this block
@export var speed_factor: float = 1.0
@export var jump_factor: float = 1.0

@export_subgroup("block_behaviour")
@export var solid := true
## If a blockA is clinged to another blockB, blockA should be broken if blockB is broken
## and blockB can only be placed on BlockA
## cling_to stores the direction the block can cling in its keys
## and the block condition it should match in its value.(see [method Block.match_condition])
##
## for instance:
## [codeblock]
## # plants only grows on land
## cling_to = {
##     Vector2i.DOWN: "soil"
## }
## [/codeblock]
@export var cling_to: Dictionary[Vector2i, String] = {}

@export_group("lighting")
@export var light_decay := -5
@export var light_level := 0

@export_group("sound")
@export var default_sound: AudioStream = preload("res://asset/sfx/Walking.wav")
@export_subgroup("footstep")
@export var footstep: AudioStream:
	get:
		return footstep if footstep or Engine.is_editor_hint() else default_sound
@export var footstep_pitch_scale := 0.8
@export var footstep_volume_db := -5
@export_subgroup("mine")
@export var destroy_or_mine: AudioStream:
	get:
		return destroy_or_mine if destroy_or_mine or Engine.is_editor_hint() else default_sound

@export_group("interact")
@export var interactable := false
@export_group("drop")
@export var drop: Array[Item] = []

@export_group("color")
#editor interface for editing atlas_coord
@export_custom(PROPERTY_HINT_RESOURCE_TYPE, "AtlasTexture", PROPERTY_USAGE_DEFAULT) var texture: AtlasTexture:
	set(p):
		if p:
			p.atlas = Block.TILE_SET
			p.changed.connect(_update_atlas_coord)
		texture = p

## The color symbolizing the block (etc. used in particles on break)
@export var color: Color
@export_tool_button("update color automatically") var update_color := _update_color

@export var meta := {}


func _update_atlas_coord() -> void:
	atlas_coord = Vector2i(texture.region.position.round() / Block.SIZE)


func _update_name() -> void:
	name = resource_path.split("/")[-1].split(".")[0]


func _update_color() -> void:
	color = Lib.ImageUtil.average(texture.get_image())
	print_rich("[color=silver]Set Color[/color]")


func enter(_block: Block) -> void:
	_enter()


func _enter() -> void:
	pass
