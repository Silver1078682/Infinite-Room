class_name StartMenu
extends Control
static var game_started := false
const SCENE_PATH = "res://scr/ui/start_menu/start_menu.tscn"


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
	Lib.scene_changed.connect(Setting.interface.update_font_size)
	World.Cursor.load_texture()


func new_game():
	Lib.change_scene_to(World.SCENE_PATH)
	World.new_game()


var displayed: Control:
	set(p_displayed):
		Lib.only_show_latter(displayed, p_displayed)
		displayed = p_displayed


func load_game():
	displayed = $SaveManager


func _on_settings_pressed() -> void:
	displayed = $SettingMenu


func back_to_main_menu():
	displayed = $MainMenu


func quit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _print_os_info():
	var os_name := OS.get_name() + "\t"
	if os_name == "Linux\t":
		os_name += OS.get_distribution_name() + " "
	os_name += OS.get_version()
	Log.info("running on: " + os_name)
	Log.info("Processor: " + OS.get_processor_name())
	Log.info("Video adapter driver: " + Lib.Arr.sum(OS.get_video_adapter_driver_info()))
