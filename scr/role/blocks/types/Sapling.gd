extends BlockConfig
@export var min_height := 4
@export var max_height := 6
@export var min_trunk_height := 4:
	get:
		var min_height = min_trunk_height
		return min_height if min_height >= 0 else _height * abs(min_height)
@export var max_trunk_height := 6:
	get:
		var max_height = max_trunk_height
		return max_height if max_height >= 0 else _height * abs(max_height)

var _height : int
var _trunk_height : int
var _leaf_height : int


func grow():
	_height = randi_range(min_height, max_height)
	_trunk_height = randi_range(min_trunk_height, max_trunk_height)
