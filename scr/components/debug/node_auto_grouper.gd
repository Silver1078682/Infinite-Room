@tool
## Yes, it's a tool
## It can(should) be simply removed in releases or builds
class_name NodeAutoGrouper
extends Node

@export var quiet_mode := true
@export_tool_button("manual_update") var manual_update := adjust_node


func _ready() -> void:
	if Engine.is_editor_hint():
		adjust_node(get_parent())
		print_if_not_quiet("nodes grouped!")
	else:
		queue_free.call_deferred()


func adjust_node(node := get_parent()):
	if node is BaseButton:
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for i in ["BaseButton", "Label", "TabContainer"]:
		if _add_or_remove(node, &"FontResizable", node.is_class(i)):
			break
	for i in node.get_children():
		adjust_node(i)


func _add_or_remove(node: Node, group: StringName, condition: bool):
	if condition:
		node.add_to_group(group, true)
		print_if_not_quiet(node.name, " add to group ", group)
		return true
	elif node.is_in_group(group):
		node.remove_from_group(group)
		print_if_not_quiet(node.name, " remove from group ", group)
	return false


func print_if_not_quiet(a, b = "", c = ""):
	if not quiet_mode:
		print(a, b, c)
