extends Node

@export_group("animation")
## name of the effect
@export var effect := ""
## Is the node affected visible on ready
@export var initial_visible := true
## The node will sleep for [prop startup_time] seconds before the animation starts
@export_range(0.0, 20.0, 0.01, "or_greater") var startup_time: float = 0.0
## How long will the animation starts
@export_range(0.0, 20.0, 0.01, "or_greater") var duration: float = 0.3
## Will The animation play automatically on ready
@export var offset := 80
@export var autoplay := true
@export var no_interupt := true
@export_subgroup("tween_property")
@export var trans : Tween.TransitionType
@export var ease: Tween.EaseType

@export_group("scope")
## What nodes will be affected
@export var applies_to := ApplyMode.SIBLINGS
enum ApplyMode { PARENT = 0, SIBLINGS = 1 }


func _ready() -> void:
	for i in _get_animated_nodes():
		if i is CanvasItem:
			#set the modulate instead of visibility to avoid layout problems of Controls
			i.modulate.a = 1 if initial_visible else 0
	if autoplay:
		play()

var _is_playing := false
func play() -> void:
	if _is_playing and no_interupt:
		return
	_is_playing = true
	await Lib.wait(startup_time)
	await _play()
	_is_playing = false

func is_playing():
	return _is_playing

func _play() -> void:
	for i in _get_animated_nodes():
		if i is CanvasItem:
			await UIAnimation.call(effect, i, _get_tween_of(i), offset, duration)


func _get_animated_nodes() -> Array[Node]:
	if applies_to == ApplyMode.SIBLINGS:
		return get_parent().get_children()
	var node: Array[Node] = []
	node.append(get_parent())
	return node

func _get_tween_of(node: Node) -> Tween:
	return node.create_tween().set_ease(ease).set_trans(trans)
