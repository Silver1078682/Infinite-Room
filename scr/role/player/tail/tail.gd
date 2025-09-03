class_name Tail
extends Line2D


func _ready() -> void:
	points_list.resize(length)
	points = points_list
	next_position.resize(length)


@export var length := 10
@export var follow: Node
@export var parent_speed_factor : Vector2
@export var min_length_between_nodes := 1.1
@export var max_length_between_nodes := 1.1
@export var curve_x : Curve
@export var curve_y : Curve
@export var initial_offset : Vector2

# don't move this function to _physics_process for sync problems
func _process(_delta: float) -> void:
	var parent_velocity = follow.velocity.normalized() * parent_speed_factor
	position = -parent_velocity
	
	var root_position = parent_velocity + initial_offset
	for i in length:
		points_list[i] = next_position[i]
		var offset = root_position - points_list[i]
		next_position[i] = root_position - offset.normalized()
		next_position[i] -= parent_velocity
		
		
		root_position = points_list[i]

	root_position = parent_velocity + initial_offset
	
	for i in length:
		points_list[i].x += curve_x.sample(float(i)/ length)
		points_list[i].y += curve_y.sample(float(i)/ length)
		points_list[i] = limit_from(root_position, points_list[i])
		
		root_position = points_list[i]
	points = points_list


var points_list: PackedVector2Array
var next_position: PackedVector2Array


func limit_from(from: Vector2, to: Vector2) -> Vector2:
	var offset = (to - from).limit_length(max_length_between_nodes)
	if absf(offset.y) < absf(offset.x):
		offset.y += 0.1
	if offset.length_squared() < min_length_between_nodes ** 2:
		offset = offset.normalized() * min_length_between_nodes
	return offset + from
