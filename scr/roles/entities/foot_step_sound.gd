extends AudioStreamPlayer2D
var parent: Entity
var parent_fsm: FSM

# the value of the [Dictionary] is currently useless
## Play the foot step sound if the parent fsm is in following state.
@export var when_to_play: Dictionary[StringName, Variant] = {
	&"StartRun": null,
	&"Run": null,
	&"Land": null,
	
}

## How long will sound extends after the source is stopped
@export var lingering_sound := 0.1

func _enter_tree() -> void:
	parent = get_parent()
	await Lib.ensure_ready(parent)
	parent_fsm = parent.fsm


func _process(_delta: float) -> void:
	if not parent_fsm or not parent_fsm.state:
		return
	if parent_fsm.state.name in when_to_play:
		var floor_block = parent.get_floor_block()
		if not floor_block:
			await Main.sleep(lingering_sound)
			stop()
			return
		if stream != floor_block.config.footstep:
			stream = floor_block.config.footstep
		volume_db = floor_block.config.footstep_volume_db
		pitch_scale = floor_block.config.footstep_pitch_scale
		if not playing:
			play(stream.get_length() * randf_range(0.1, 0.5))
	else:
		await Main.sleep(lingering_sound)
		stop()
