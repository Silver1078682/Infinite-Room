extends Timer


func _on_timeout() -> void:
	SL.save_game()
	wait_time = Setting.get_setting("Game", "intervals_between_autosave")
