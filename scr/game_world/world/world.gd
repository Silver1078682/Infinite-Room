class_name World
extends Node2D
## As its name suggest, the [World] is the environment player directly interact with in game.

#namespaces
const Map: GDScript = preload("res://scr/game_world/map/map.gd")
const Cursor: GDScript = preload("res://scr/game_world/cursor/cursor.gd")
const Camera := preload("res://scr/game_world/camera/camera.gd")

static var instance: World
static var save_name: String


# This function is used to organize nodes in a better manner
## Add a grandchild node under node named [param under].
static func add_node(node: Node, under: NodePath = "."):
	instance.get_node(under).add_child(node)


func _init():
	assert(not instance, "There can be only one World instance at one time")
	instance = self
	Log.info("World Instance Initialized")


func _ready() -> void:
	Log.info("World Instance Ready")


# shortcuts
func _input(_event: InputEvent) -> void:
	if World.input("just_pressed", &"ui_home"):
		SL.save_game()
	if _event.is_action_pressed("pause_game"):
		pause()


## pause the game
func pause():
	assert(not get_tree().paused)
	get_tree().paused = true
	%UI/%Pause.show()
	Room.current.update_time()
	SL.save_game()


## resume the game
func resume() -> void:
	assert(get_tree().paused)
	get_tree().paused = false
	%UI/%Pause.hide()
	Room.current.start_time = Time.get_ticks_usec()


static var input_cut := false

## start a new game
static func new_game():
	save_name = SaveManager.get_save_name_from_time()
	RoomManager.enter_room(RoomManager.create_a_room("Nature"))
	await World.instance.ready
	SL.save_game()

## a custom input listener, only compatible for "pressed", "just_pressed", "just_released"
## ignore input when [prop input_cut] set true
static func input(func_name: StringName, action_name: StringName, exact_match := false):
	if input_cut:
		return false
	return Input.call("is_action_" + func_name, action_name, exact_match)
