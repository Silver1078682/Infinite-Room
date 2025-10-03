extends Timer
## Timer used for automatic saving

# as you see, the setting "intervals_between_autosave" does not take effect immediately
# TODO This seems irreasonable, gonna fix it one day.
func _on_timeout() -> void:
	SL.save_game()
	wait_time = Setting.get_setting("Game", "intervals_between_autosave")
