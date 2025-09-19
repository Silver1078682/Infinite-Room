class_name Pause
extends ColorRect
@onready var displayed: Control = %MainMenu:
	set(p_displayed):
		Lib.only_show_latter(displayed, p_displayed)
		displayed = p_displayed


func _on_resume_pressed() -> void:
	World.instance.resume_game()


func _on_setting_pressed() -> void:
	displayed = %Setting


func _on_start_menu_pressed() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	Lib.change_scene_to(StartMenu.SCENE_PATH)


func back_to_main_menu() -> void:
	displayed = %MainMenu


func _on_stats_pressed() -> void:
	displayed = %Stats
