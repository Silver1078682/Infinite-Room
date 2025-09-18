class_name Main
extends Node2D
## The [Main] is a running game, or more precisely The world player is in.
# SO WHY DONT RENAME IT TO [World]!!!!???

const SCENE_PATH = "res://scr/game_world/main/main.tscn"

#namespaces
const Map: GDScript = preload("res://scr/game_world/map/map.gd")
const Cursor: GDScript = preload("res://scr/game_world/cursor/cursor.gd")
const Camera: GDScript = preload("res://scr/game_world/camera/camera.gd")

static var instance: Main
static var save_name: String


# This function is used to organize nodes in a better manner
## Add a grandchild node under node named [param under].
static func add_node(node: Node, under: NodePath = "."):
	instance.get_node(under).add_child(node)


func _init():
	assert(not instance, "There can be only one Main instance at one time")
	instance = self
	Log.info("Main Instance Initialized")


func _ready() -> void:
	Log.info("Main Instance Ready")


func _input(_event: InputEvent) -> void:
	if Main.input("just_pressed", &"ui_home"):
		SL.save_game()
	if _event.is_action_pressed("pause_game"):
		pause_game()


func pause_game():
	get_tree().paused = true
	%UI/%Pause.show()
	Room.current.update_time()
	SL.save_game()


func resume_game() -> void:
	get_tree().paused = false
	%UI/%Pause.hide()
	Room.current.start_time = Time.get_ticks_usec()


static var input_cut := false


## a custom input listener, only compitable for "pressed", "just_pressed", "just_released"
## ignore input when [prop input_cut] set true
static func input(func_name: StringName, action_name: StringName, exact_match := false):
	if input_cut:
		return false
	return Input.call("is_action_" + func_name, action_name, exact_match)


static func new_game():
	save_name = SaveManager.get_save_name_from_time()
	RoomManager.enter_room(RoomManager.create_a_room("Nature"))
	await Main.instance.ready
	SL.save_game()
