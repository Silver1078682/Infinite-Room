extends AudioStreamPlayer2D
var parent: Entity
var parent_fsm: FSM
@export var when_to_play: Dictionary[StringName, Variant] = {
	&"StartRun": null,
	&"Run": null,
	&"Land": null,
	
}
@export var aftersound_length := 0.1

func _enter_tree() -> void:
	parent = get_parent()
	await Lib.ensure_ready(parent)
	parent_fsm = parent.fsm


func _process(delta: float) -> void:
	if not parent_fsm or not parent_fsm.state:
		return
	if parent_fsm.state.name in when_to_play:
		var floor = parent.get_floor_block()
		if not floor:
			await Lib.wait(aftersound_length)
			stop()
			return
		if stream != floor.config.footstep:
			stream = floor.config.footstep
		volume_db = floor.config.footstep_volume_db
		pitch_scale = floor.config.footstep_pitch_scale
		if not playing:
			play(stream.get_length() * randf_range(0.1, 0.5))
	else:
		await Lib.wait(aftersound_length)
		stop()
