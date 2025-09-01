extends Node

@export var effect := ""
@export var initial_visible := true
@export_range(0.0, 20.0, 0.1, "or_greater") var startup_time: float = 0
@export var autoplay := true
@export var applies_to := ApplyMode.SIBLINGS
enum ApplyMode { PARENT = 0, SIBLINGS = 1 }


func _ready() -> void:
	for i in _get_animated_nodes():
		if i is CanvasItem:
			#set the modulate instead of visibility to avoid layout problems of Controls
			i.modulate.a = 1 if initial_visible else 0
	if autoplay:
		play()


func play() -> void:
	await Lib.wait(startup_time)
	_play()


func _play() -> void:
	for i in _get_animated_nodes():
		if i is CanvasItem:
			UIAnimation.call(effect, i)


func _get_animated_nodes() -> Array[Node]:
	if applies_to == ApplyMode.SIBLINGS:
		return get_parent().get_children()
	var node: Array[Node] = []
	node.append(get_parent())
	return node
