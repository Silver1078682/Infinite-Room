class_name Block
extends RefCounted
## Basic component of the world.
## Life process of a block: init, enter, mined(optional), freed
## See [Block.config]

const Mine = preload("res://scr/roles/blocks/mine/mine.gd")

## The size of a BLOCK in pixels
const SIZE = Vector2(16, 16)

# we can assure that every valid block has a valid config.
# To make that happens, avoid using Block.new() in any circumstance
## The [BlockConfig] of the block
@export var config: BlockConfig

## The current coordinate the block is in
var coord: Vector2i

## see [prop block cling_to]
var neighbor_bind: Dictionary[Block, Vector2i] = {}

## The [Node] bind to the [Block]
var node: Node


## Create a block. Return null on failure
static func create(block_name: StringName) -> Block:
	if not block_name:
		return null
	var block := Block.new()
	block.config = load(ResPath.BLOCK.file % block_name)
	if not block:
		Lib.Warning.does_not_exist(block_name, "BlockConfig")
		assert(block)
		return null
	return block


func enter():
	config.enter(self)

## see [class Block.Mine]
var mine: Mine = null


func mined(speed: float, delta: float) -> void:
	if not mine:
		mine = Mine.SCENE.instantiate()
		Main.add_node.call_deferred(mine, "Mines")
		mine.block = self
	mine.mined(speed, delta)


## Break the block in a flash
func instant_break():
	mined(INF, 1)


func notify_exit() -> void:
	if node:
		node.queue_free()
	for i in neighbor_bind:
		#WARNING if two adjacent blocks get each other bind in this list, will cause infinite loops
		i.instant_break()


#
func get_save() -> Dictionary[String, Variant]:
	return {"config": config.name}


## if the block match the [param condition][br]
## for instance:
## [codeblock]
## var block = Block.create("Frame")
## block.match_condition("Frame") #return true
## block.match_condition("solid") #return true
## [/codeblock]
func match_condition(condition: StringName) -> bool:
	if condition == config.name:
		return true
	const SOLID = &"solid"
	if condition == SOLID and config.solid:
		return true
	if condition in config.meta:
		if config.meta[condition]:
			return true
	return false


static func load_save(dictionary) -> Block:
	var config_name = dictionary["config"]
	return Block.create(config_name)
