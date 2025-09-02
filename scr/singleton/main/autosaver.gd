extends Timer


func _on_timeout() -> void:
	SL.save_game()
	wait_time = Setting.auto_save_time_interval
