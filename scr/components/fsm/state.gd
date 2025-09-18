class_name State
extends Node
@onready var fsm : FSM = get_parent()
@onready var machine: Node = fsm.machine
@export var exit_when_animation_finished := false

func enter() -> void:
	if fsm.animated_sprite:
		fsm.animated_sprite.play(self.name)
		if exit_when_animation_finished:
			var anim_signal := fsm.animated_sprite.animation_finished
			if not anim_signal.is_connected(change_to):
				anim_signal.connect(change_to)
	_enter()

func exit() -> void:
	if fsm.animated_sprite and exit_when_animation_finished:
		fsm.animated_sprite.animation_finished.disconnect(change_to)
	_exit()

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _behaviour(_delta: float) -> void:
	pass

func _physics_behaviour(_delta: float) -> void:
	pass

@export var default_destination := ""

func change_to(p_state_name: NodePath = default_destination) -> void:
	fsm.change_to(p_state_name)
