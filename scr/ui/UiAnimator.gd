extends Node
## Animate a node

@export_group("animation")
## name of the effect
@export var effect := ""
## Is the node affected visible on ready
@export var initial_visible := true
@export var offset := Vector2.ZERO
@export_subgroup("when_to_play")
## Whether The animation play automatically on ready
@export var autoplay := false
## if a node under scope has signal [prop play_signal], and the signal is_emitted.
## Play the animation on that specific node
@export var play_signal := ""
@export var no_interrupt := true
@export_subgroup("tween_property")
## The node will sleep for [prop startup_time] seconds before the animation starts
@export_range(0.0, 20.0, 0.01, "or_greater") var startup_time: float = 0.0
## How long will the animation starts
@export_range(0.0, 20.0, 0.01, "or_greater") var duration: float = 0.3
@export var trans_type: Tween.TransitionType
@export var ease_type: Tween.EaseType

@export_group("scope")
## What nodes will be affected
## This property is can't be set runtime!
@export var applies_to := ApplyMode.SIBLINGS:
	set(p_applies_to):
		applies_to = p_applies_to
		if is_node_ready():
			Log.warning("Trying to set the [applies to] property of an [Animator] runtime, which has no effect!")

enum ApplyMode { PARENT = 0, SIBLINGS = 1, NONE = 2 }


func _ready() -> void:
	for i in _get_animated_nodes():
		if i is CanvasItem:
			#set the modulate instead of visibility to avoid layout problems of Controls
			i.modulate.a = 1 if initial_visible else 0
		if play_signal:
			connect_signal(i)
	if autoplay:
		play()


func play() -> void:
	if _is_playing and no_interrupt:
		return
	await Lib.wait(startup_time)
	for i in _get_animated_nodes():
		if i is CanvasItem:
			await play_single(i)


func play_single(node: Node) -> void:
	_is_playing = true
	if effect:
		_play_single(node)
	_is_playing = false


func _play_single(node: Node):
	await UIAnimation.call(effect, node, _get_tween_of(node), offset, duration)


func is_playing() -> bool:
	return _is_playing


var _is_playing := false


func _get_animated_nodes() -> Array[Node]:
	var node: Array[Node] = []
	match applies_to:
		ApplyMode.SIBLINGS:
			return get_parent().get_children()
		ApplyMode.PARENT:
			node.append(get_parent())
			return node
		_:
			return node


func connect_signal(node: Node, callable := play_single) -> void:
	if node.has_signal(play_signal):
		node.connect(play_signal, callable.bind(node))
	else:
		Log.warning("No signal named %s in node %s" % [play_signal, node])


func _get_tween_of(node: Node) -> Tween:
	return node.create_tween().set_ease(ease_type).set_trans(trans_type)
