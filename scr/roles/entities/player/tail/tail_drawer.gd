extends CharacterBody2D
## draw the physics state of a tail in a Line2D

@export var line2d: Line2D

@export var min_length_between_nodes := 1.5
@export var max_length_between_nodes := 2.0:
	set(p_max_length_between_nodes):
		max_length_between_nodes = maxf(p_max_length_between_nodes, min_length_between_nodes)


func _process(_delta: float) -> void:
	# If the tip of the tail(which collide with terrain) is too far away from the root.
	# It's likely that it is STUCK! we therefore need to remove its collision mask on terrain.

	_update_cnt += 1
	if _update_cnt >= PHYSICS_ENABLE_CHECK_LOOP:
		var body: RigidBody2D = get_child(-1)
		var enabled = body.position.length_squared() <= MAX_PHYSICS_ENABLE_LENGTH_SQUARED
		body.collision_mask = 1 if enabled else 0

	line2d.clear_points()
	var root_position = Vector2.ZERO
	for i in get_children():
		if i is RigidBody2D:
			var p: Vector2 = i.position
			p = limit_from(root_position, p)
			line2d.add_point(p)
			root_position = p


const PHYSICS_ENABLE_CHECK_LOOP := 5
var _update_cnt := PHYSICS_ENABLE_CHECK_LOOP
const MAX_PHYSICS_ENABLE_LENGTH_SQUARED := 300.0


func limit_from(from: Vector2, to: Vector2) -> Vector2:
	var offset = (to - from).limit_length(max_length_between_nodes)
	if offset.length_squared() < min_length_between_nodes ** 2:
		offset = offset.normalized() * min_length_between_nodes
	return from + offset
