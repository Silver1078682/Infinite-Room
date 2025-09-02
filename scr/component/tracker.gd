class_name Tracker
extends Label
## A label which prints a [Node]'s properties
static var enabled := true

## Print the properties declared by classes in this [Array].
@export var class_get: PackedStringArray

## Print the properties in this [Array].
@export var property_get: PackedStringArray

## Won't print the properties in this [Array].
## Even if its in property_get.
@export var property_filter: PackedStringArray

## Node for the node to analyze.
@export var node: Node

# NodePath of all properties required to get.
var _property_to_be_printed: Array

@export var format := "%s | %s \n"
@export var max_ordering := true
@export var tracking := false

static func _static_init() -> void:
	Console.add_command("tracker", _command_tracker, "Turn on/off the debug tracker.")


static func _command_tracker(on: bool):
	Main.instance.get_tree().call_group(&"Tracker", "set_tracking", on)

func set_tracking(on: bool):
	tracking = on
	visible = on

func _ready() -> void:
	add_to_group(&"Tracker")
	_handle_class_get(class_get)
	if max_ordering:
		z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	for node_path in property_get:
		_property_to_be_printed.append(node_path)
	for node_path in property_filter:
		_property_to_be_printed.erase(node_path)


func _process(_delta) -> void:
	if not tracking:
		return
	text = ""
	for node_path in _property_to_be_printed:
		var value = _get_value_by_node_path(node_path)
		text += format % [node_path, value]
	add_theme_constant_override("outline_size", 0)


# Handle the property list in the format as follow.
# [{"name":"xxx","class_name":"xxx",...},{...},...,{...}],
# and add all properties to class_get Array.
func _parse_property_list(property_list: Array[Dictionary]) -> void:
	for property_dict: Dictionary in property_list:
		var property_name: String = property_dict["name"]
		if !(property_name in property_filter or property_name.ends_with(".gd")):
			_property_to_be_printed.append(property_name)


func _handle_class_get(class_arr: PackedStringArray) -> void:
	for each_class_name in class_arr:
		# built_in class
		if ClassDB.class_exists(each_class_name):
			_parse_property_list(ClassDB.class_get_property_list(each_class_name))
		# custom class
		else:
			for custom_class in ProjectSettings.get_global_class_list():
				if StringName(each_class_name) == custom_class["class"]:
					var script: Script = load(custom_class["path"])
					_parse_property_list(script.get_script_property_list())


func _get_node_to_be_tracked() -> Node:
	return node if node else get_parent()


func _get_value_by_node_path(prop_path: String):
	if not prop_path.begins_with("$"):
		return _get_node_to_be_tracked().get(prop_path)
	var node_path = prop_path.right(-1)
	var node_path_spilt = node_path.split(":", false, 1)
	var another_node := _get_node_to_be_tracked().get_node_or_null(node_path_spilt[0])
	if another_node:
		return another_node.get_indexed(node_path_spilt[1])
	else:
		return _get_node_to_be_tracked().get_indexed(node_path_spilt[1])
