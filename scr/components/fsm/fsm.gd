class_name FSM
extends Node

@export var machine: Node
@export var initial_state: State
@export var animated_sprite: AnimatedSprite2D

@export var ignore_same_state_change := false
var state: State = null:
	set(p_state):
		if p_state == state and ignore_same_state_change:
			return
		if state:
			state.exit()
		if p_state:
			p_state.enter()
		state = p_state


func _process(delta: float) -> void:
	if not state:
		return
	state._behaviour(delta)


func _physics_process(delta: float) -> void:
	if not state:
		return
	state._physics_behaviour(delta)


func change_to(p_state_name: NodePath):
	state = get_node(p_state_name)


func _ready() -> void:
	state = initial_state


func is_state(state_name: StringName) -> bool:
	return state.name == state_name


func _to_string() -> String:
	return "<FSM>: %s" % state.name
