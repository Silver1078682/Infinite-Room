extends Node
## Main
## Used to manage scenes and control over the whole game.

## when the scene is changed
signal scene_changed
const WORLD_SCENE = preload("uid://8f1u7k6r8i4r")

static var has_application_started := false


func _init() -> void:
	# automatically change the font size on scene is changed
	# you may feel like moving this line under Setting.gd script
	# but it cause NullPointerException due to the order in which
	# Autoload and static classes is loaded
	## TBD now that setting is refactored, try it out later
	#scene_changed.connect(Setting.interface.update_font_size)
	pass

## Wait [para time] seconds.
## use await keyword before the function.
func sleep(time: float) -> void:
	await get_tree().create_timer(time).timeout

## start a new game
func new_game():
	if get_tree().current_scene is World:
		Log.warning("A world instance is already running, can not start a new game")
	_change_scene_to(WORLD_SCENE)
	World.new_game()


## load a game
func load_game(save_name: String):
	_change_scene_to(WORLD_SCENE)
	SL.load_game(save_name)


## quit the game
func quit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


## change the current scene
func _change_scene_to(scene: PackedScene):
	scene_changed.emit()
	get_tree().change_scene_to_packed(scene)
	Log.info("Changing scene to ... %s" % scene.resource_path)
