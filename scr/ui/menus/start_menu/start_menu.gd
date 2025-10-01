class_name StartMenu
extends Control
static var game_started := false
const SCENE_PATH = "res://scr/ui/menus/start_menu/start_menu.tscn"


func _ready() -> void:
	if not game_started:
		_on_boot()
		game_started = true
	displayed = $MainMenu
	%LoadGame.disabled = not SaveManager.has_any_save()
	Log.info("Start Menu Ready")


func _on_boot():
	Log.notice("Game started")
	_print_os_info()
	World.Cursor.load_texture()


var displayed: Control:
	set(p_displayed):
		Lib.only_show_latter(displayed, p_displayed)
		displayed = p_displayed


func back_to_main_menu():
	displayed = $MainMenu


func _on_new_game_pressed() -> void:
	Main.new_game()


func _on_settings_pressed() -> void:
	displayed = $SettingMenu


func _on_quit_game_pressed() -> void:
	Main.quit_game()


func _on_load_game_pressed() -> void:
	displayed = $SaveManager


func _print_os_info():
	var os_name := OS.get_name() + "\t"
	if os_name == "Linux\t":
		os_name += OS.get_distribution_name() + " "
	os_name += OS.get_version()
	Log.info("running on: " + os_name)
	Log.info("Processor: " + OS.get_processor_name())
	Log.info("Video adapter driver: " + Lib.Arr.sum(OS.get_video_adapter_driver_info()))
