## TODO
@tool
extends BlockConfig
@export var min_height := 4
@export var max_height := 6
@export var min_trunk_height := 4:
	get:
		var value = min_trunk_height
		return value if value >= 0 else _height * abs(value)
@export var max_trunk_height := 6:
	get:
		var value = max_trunk_height
		return value if value >= 0 else _height * abs(value)

var _height : int
var _trunk_height : int
var _leaf_height : int


func grow():
	_height = randi_range(min_height, max_height)
	_trunk_height = randi_range(min_trunk_height, max_trunk_height)
	_leaf_height = _height - _trunk_height