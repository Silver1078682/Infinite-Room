extends SubViewport

var _update_cnt := 0
const UPDATE_LOOP = 5
func _process(delta: float) -> void:
	_update_cnt += 1
	if _update_cnt >= UPDATE_LOOP:
		render_target_update_mode = SubViewport.UPDATE_ONCE
		_update_cnt = 0
