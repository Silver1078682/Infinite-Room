extends Node2D
## Mouse cursor

## size in pixel
const SIZE = Vector2(8, 8)

## Don't use Input.CURSOR_* if possible,
enum Type {
	ARROW = Input.CURSOR_ARROW,
	HAND = Input.CURSOR_POINTING_HAND,
	INTERACT = Input.CURSOR_CROSS,
	FORBIDDEN = Input.CURSOR_FORBIDDEN,
}

const TILE_SHEET = preload("uid://dr8dptmx8xtrv")
## coordinate of the mouse cursor (relative to the room)
static var coord:
	get:
		return World.Map.to_coord(_instance.get_global_mouse_position())
var _last_coord

## emitted when the mouse move from one coordinate to another
signal coord_changed

static var _instance: Node2D


func _ready() -> void:
	_instance = self


static func load_texture() -> void:
	var type := Type.keys()
	for i in type.size():
		Input.set_custom_mouse_cursor(_read_at(Vector2i(i, 0)), Type[type[i]])


func _process(_delta: float) -> void:
	position = get_global_mouse_position()
	if _last_coord != coord:
		coord_changed.emit()
		var block := Room.current.get_block_safe(coord)
		if block and block.config.interactive:
			shape_override(Type.INTERACT)
		else:
			shape_override(Type.ARROW)
	_last_coord = coord


#get the [Image] at the given coordinate from the
static func _read_at(at: Vector2i) -> Image:
	var result = AtlasTexture.new()
	result.atlas = TILE_SHEET
	result.region.position = Vector2(at) * SIZE
	result.region.size = SIZE
	result.filter_clip = false
	result = result.get_image()
	var cursor_scale := _get_cursor_scale()
	Lib.ImageUtil.scale(result, Vector2.ONE * cursor_scale, Image.INTERPOLATE_NEAREST)
	return result

## get the cursor scale for current window
static func _get_cursor_scale() -> int:
	return 2


#if OS.window_size.y > 1500:
#	 Load large hardware cursor here.
#elif OS.window_size.y > 1000:
#	 Load medium hardware cursor here.
#else:
#	 Load small hardware cursor here.


## override current mouse cursor shape,
## NOTE: won't take effect immediately until player moves the mouse
## [code_block]
## shape_override(Cursor.Type.ARROW)
## [/code_block]
static func shape_override(shape: Type):
	Input.set_default_cursor_shape((shape as int))
