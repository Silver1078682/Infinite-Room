@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_2d.svg")
extends PhantomCamera2D
## Camera

## How much to scale up or scale down for each time
const ZOOM_SCALE = 1.0
const MIN_ZOOM = 2.0
const MAX_ZOOM = 4.0
@onready var _target_zoom := zoom

static var instance: Main.Camera
## coordinate of the camera, get-only attribute
var coord: Vector2i:
	get:
		return Main.Map.to_coord(position)


func _init() -> void:
	instance = self


func _ready() -> void:
	super()
	Log.info("Camera Instance Ready")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if Input.is_action_just_pressed("zoom_in", true):
		_target_zoom += Vector2.ONE * ZOOM_SCALE
	elif Input.is_action_just_pressed("zoom_out", true):
		_target_zoom -= Vector2.ONE * ZOOM_SCALE
	_target_zoom = _target_zoom.clampf(MIN_ZOOM, MAX_ZOOM)
	zoom = zoom.move_toward(_target_zoom, ZOOM_SCALE / 20)


const CAMERA_BORDER = 40


func set_limit_x(left := 0, right := Room.current.size().x):
	set_limit_left(int(left * Block.SIZE.x - CAMERA_BORDER))
	set_limit_right(int(right * Block.SIZE.x + CAMERA_BORDER))
