extends "res://scr/ui/UiAnimator.gd"
## Restore a node to its inital stage before an animation is played
## The property of the node will be used in restoration animation

var modified_nodes: Dictionary[Node, Array] = {}
const UIAnimator := preload("res://scr/ui/UiAnimator.gd")
@export var play_animator: UIAnimator
@export var restorable_properties: Array[String] = ["position"]


func _ready() -> void:
	super()


func restore(node: Node):
	if not node in modified_nodes:
		return
	var tween = _get_tween_of(node).set_parallel()
	for i in restorable_properties.size():
		var prop = restorable_properties[i]
		var value = modified_nodes[node][i]
		tween.tween_property(node, prop, value, duration)


func _play_single(node: Node) -> void:
	await play_animator.play_single(node)
	modified_nodes.get_or_add(node, [])
	for prop in restorable_properties:
		modified_nodes[node].append(node.get(prop))

func connect_signal(node: Node, callable := play_single) -> void:
	play_animator.connect_signal(node, self.play_single)
	super(node, self.restore)
