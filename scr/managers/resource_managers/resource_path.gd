extends Node
## ResPath[br]
## This Node use a hacky way to locate a resource employing RID.[br]
## It make sure that resource can be located even if the file structure is changed.
## e.g file renamed, directory moved elsewhere
## [codeblock]
## # access a resoure path
## print(ResPath.BLOCK.dir)     # /path/to/directory/
## print(ResPath.BLOCK.file)     # /path/to/directory/%s.tres
## load(ResPath.ROOM_THEME.file % "Nature")
## [/codeblock]


@export var _room_theme: RoomTheme
@onready var ROOM_THEME := _ResourceDir.new(_room_theme)
@export var _block: BlockConfig
@onready var BLOCK := _ResourceDir.new(_block)
@export var _item: Item = preload("uid://c0eqnh7tcuur")
@onready var ITEM := _ResourceDir.new(_item)

class _ResourceDir:
	func _get_dir_path(resource: Resource) -> String:
		var path := resource.resource_path
		var directory_split := path.split("/").slice(0, -1)
		var dir_path := "/".join(directory_split) + "/"
		return dir_path

	func _init(locator: Resource) -> void:
		_locator_resource = locator
		_dir = _get_dir_path(_locator_resource)

	var _locator_resource: Resource
	var _dir: String
	var dir: String:
		set(p):
			Lib.Warning.read_only("dir", p)
		get:
			return _dir
	var file: String:
		get:
			return _dir + "%s.tres"
