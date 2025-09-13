extends Node
var raised_nodes: Dictionary[Node, Vector2] = {}
@export var offset := Vector2(0, -5)
@export var trans_type: Tween.TransitionType
@export var ease_type: Tween.EaseType
@export var duration: float = 0.2

@export var applies_to: ApplyMode
enum ApplyMode { PARENT = 0, SIBLINGS = 1 }

var _internal


func _get_animated_nodes() -> Array[Node]:
	if applies_to == ApplyMode.SIBLINGS:
		return get_parent().get_children()
	var node: Array[Node] = []
	node.append(get_parent())
	return node


func _ready() -> void:
	for i in _get_animated_nodes():
		if i is Control:
			i.mouse_entered.connect(raise.bind(i))
			i.mouse_exited.connect(drop.bind(i))


func _get_tween_of(node: Node) -> Tween:
	return node.create_tween().set_ease(ease_type).set_trans(trans_type)


func raise(node: Node):
	raised_nodes.get_or_add(node, node.position)
	_drag_to(node, raised_nodes[node] + offset)


func drop(node: Node):
	if not node in raised_nodes:
		return
	_drag_to(node, raised_nodes[node])


func _drag_to(node: Node, position: Vector2):
	await _get_tween_of(node).tween_property(node, "position", position, duration).finished
