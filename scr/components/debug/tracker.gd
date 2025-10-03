class_name Tracker
extends Label
## A [Label] that tracks and prints a [Node]'s properties
## After the [Tracker] is ready.
## You need to manually update the property list for changes on *_filter or *_get properties to take effect

## a Node for the node to analyze. Track its parent if set null.
@export var node: Node
## Whether the [Tracker] will track the node.
@export var tracking := false

@export_group("scope")
## Will prints all properties declared by the classes in [class_get].
## will also print properties declared by its parent class,
## For instance, when [code]"Node2D"[/code] is in the array,
## will include property from [CanvasItem] and [Node].
@export var class_get: PackedStringArray

## Won't print the properties declared by the classes in [class_filter].
## Even if the property is under the scope of class_get or property_get.
@export var class_filter: PackedStringArray

## Print the properties in this [Array].
## With a $ prefix, you can track the property from another [Node] at given [NodePath],
## for instance, a valid property_get list may include:
## [codeblock]
## property_get = ["$CollisionShape.disabled", "position:x", "rotation"]
## [/codeblock]
@export var property_get: PackedStringArray

## Won't print the properties in this [Array].
## Even if the property is under the scope of class_get or property_get.
@export var property_filter: PackedStringArray

# NodePath of all properties required to get.
var _property_to_be_printed: Array

@export_group("visual")
## format in which the properties is printed
@export var format := "%s | %s \n"
## Whether the [Tracker] will be automatically set to the top of the [CanvasLayer] it is in.
@export var max_ordering := true


static func _static_init() -> void:
	Console.add_command("tracker", _command_tracker, "Turn on/off the debug tracker.")


static func _command_tracker(on: bool):
	World.instance.get_tree().call_group(&"Tracker", "set_tracking", on)


## enable/disable the [Tracker], will hide the [Tracker] if set disabled.
func set_tracking(on: bool):
	tracking = on
	visible = on


func update_property_list():
	_property_to_be_printed.clear()
	for each_class_name in class_get:
		for property in _get_property_list_from_class(each_class_name):
			_property_to_be_printed.append(property)
	for node_path in property_get:
		_property_to_be_printed.append(node_path)
	for node_path in property_filter:
		_property_to_be_printed.erase(node_path)


func _ready() -> void:
	add_to_group(&"Tracker")
	if max_ordering:
		z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	update_property_list()


func _process(_delta) -> void:
	if not tracking:
		return
	text = ""
	for node_path in _property_to_be_printed:
		var value = _get_value_by_node_path(node_path)
		text += format % [node_path, value]
	add_theme_constant_override("outline_size", 0)


func _get_property_list_from_class(the_class_name: StringName) -> Array[Dictionary]:
	# built_in class
	if ClassDB.class_exists(the_class_name):
		return ClassDB.class_get_property_list(the_class_name).map(func(dict): return dict["name"])
		
	# custom class
	else:
		for custom_class in ProjectSettings.get_global_class_list():
			if StringName(the_class_name) == custom_class["class"]:
				var script: Script = load(custom_class["path"])
				return script.get_script_property_list().map(func(dict): return dict["name"])
	return []


func _get_node_to_be_tracked() -> Node:
	return node if node else get_parent()


func _get_value_by_node_path(prop_path: String):
	if not prop_path.begins_with("$"):
		return _get_node_to_be_tracked().get_indexed(prop_path)
	# with $ prefix
	prop_path = prop_path.right(-1)  # remove $ prefix
	var node_path = prop_path.split(":", false, 1)  # get the node
	var another_node := _get_node_to_be_tracked().get_node_or_null(node_path[0])
	if another_node:
		return another_node.get_indexed(node_path[1])
	else:
		return "Node not found @ " + node_path
