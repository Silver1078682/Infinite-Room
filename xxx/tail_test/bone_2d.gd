extends CharacterBody2D
@export var line2d: Line2D
@export var follow: Node2D
@export var max_length_between_nodes := 2.0
@export var min_length_between_nodes := 1.5


func _process(delta: float) -> void:
	line2d.clear_points()
	var root_position = Vector2.ZERO
	for i in get_children():
		if i is RigidBody2D:
			var p: Vector2 = i.position
			p = limit_from(root_position, p)
			line2d.add_point(p)
			root_position = p


func limit_from(from: Vector2, to: Vector2) -> Vector2:
	var offset = (to - from).limit_length(max_length_between_nodes)
	if offset.length_squared() < min_length_between_nodes ** 2:
		offset = offset.normalized() * min_length_between_nodes
	return from + offset
