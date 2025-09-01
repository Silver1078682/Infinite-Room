class_name Main
extends Node2D

const SCENE_PATH = "res://scr/singleton/main/main.tscn"

const Map: GDScript = preload("res://scr/role/room/map.gd")
const Cursor: GDScript = preload("res://scr/singleton/cursor/cursor.gd")
const Camera := preload("res://scr/singleton/camera/camera.gd")

static var instance: Main
static var save_name: String


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
static func input(func_name: StringName, action_name: StringName, exact_match := false):
	if input_cut:
		return false
	return Input.call("is_action_" + func_name, action_name, exact_match)


const BASE := preload("res://scr/role/room/theme/base.tres")
static func new_game():
	save_name = SaveManager.get_save_name_from_time()
	Room.current = BASE.create()
	await Main.instance.ready
	SL.save_game()
