# MIT License
# Copyright (c) 2025 Rock Gementiza
# NOTE the code has been modified (a lot)
# The codes are intended for Controls, but seemingly applies to all Node2D
extends Node

var default_offset := 8.0
var default_speed := 0.3


func get_node_center(node: CanvasItem) -> Vector2:
	return (get_viewport().get_visible_rect().size.x / 2) - (node.size.x / 2)


func slide_from_side(
	node: CanvasItem,
	side := SIDE_TOP,
	offset := default_offset,
	speed := default_speed,
):
#region slide from
	match side:
		SIDE_LEFT:
			await slide_from_left(node, offset, speed)
		SIDE_RIGHT:
			await slide_from_right(node, offset, speed)
		SIDE_BOTTOM:
			await slide_from_bottom(node, offset, speed)
		SIDE_TOP:
			await slide_from_top(node, offset, speed)


func slide_from_left(node, offset := default_offset, speed := default_speed):
	node.position.x = -node.size.x
	await _custom_tween_property(node, "position:x", offset, speed, Tween.EASE_OUT).finished


func slide_from_right(node, offset := default_offset, speed := default_speed):
	node.position.x = get_viewport().size.x
	var vp_size = get_viewport().get_visible_rect().size.x
	var target = (vp_size - node.size.x) - offset
	await _custom_tween_property(node, "position:x", target, speed, Tween.EASE_OUT).finished


func slide_from_top(node, offset := default_offset, speed := default_speed):
	node.position.y = -node.size.y
	await _custom_tween_property(node, "position:y", offset, speed, Tween.EASE_OUT).finished


func slide_from_bottom(node, offset := default_offset, speed := default_speed):
	node.position.y = get_viewport().size.y
	var vp_size = get_viewport().get_visible_rect().size.y
	var target = (vp_size - node.size.y) - offset
	await _custom_tween_property(node, "position:y", target, speed, Tween.EASE_OUT).finished


#endregion


func slide_to_side(
	node: CanvasItem,
	side := SIDE_TOP,
	offset := default_offset,
	speed := default_speed,
):
#region slide to
	match side:
		SIDE_LEFT:
			await slide_to_left(node, offset, speed)
		SIDE_RIGHT:
			await slide_to_right(node, offset, speed)
		SIDE_BOTTOM:
			await slide_to_bottom(node, offset, speed)
		SIDE_TOP:
			await slide_to_top(node, offset, speed)


func slide_to_left(node, offset := default_offset, speed := default_speed):
	await _custom_tween_property(node, "position:x", -node.size.x, speed, Tween.EASE_IN).finished


func slide_to_right(node, offset := default_offset, speed := default_speed):
	await _custom_tween_property(node, "position:x", get_viewport().size.x, speed, Tween.EASE_IN).finished


func slide_to_top(node, offset := default_offset, speed := default_speed):
	await _custom_tween_property(node, "position:x", -node.size.y, speed, Tween.EASE_IN).finished


func slide_to_bottom(node, offset := default_offset, speed := default_speed):
	await _custom_tween_property(node, "position:x", get_viewport().size.y, speed, Tween.EASE_IN).finished


#endregion


func pop(node, speed := default_speed):
	node.show()
	node.pivot_offset.x = node.size.x / 2
	node.pivot_offset.y = node.size.y / 2
	node.scale = Vector2.ZERO

	await _custom_tween_property(node, "scale", Vector2.ONE, speed, Tween.EASE_OUT).finished


func shrink(node, speed := default_speed):
	await _custom_tween_property(node, "scale", Vector2.ZERO, speed, Tween.EASE_IN)
	node.hide()


func fade_in(node: CanvasItem):
	node.show()
	await _custom_tween_property(node, "modulate:a", 1, default_speed, Tween.EASE_IN).finished


func from_left_to_center(node):
	await _custom_tween_property(node, "position:x", get_node_center(node), default_speed, Tween.EASE_OUT).finished


func from_center_to_left(node):
	await _custom_tween_property(node, "position:x", -node.size.x, default_speed, Tween.EASE_IN)


func from_right_to_center(node):
	node.position.x = get_viewport().get_visible_rect().size.x
	await _custom_tween_property(node, "position:x", get_node_center(node), default_speed, Tween.EASE_OUT)


func from_center_to_right(node):
	await _custom_tween_property(node, "position:x", node.size.x, default_speed, Tween.EASE_IN)


func _create_custom_tween(ease: Tween.EaseType) -> Tween:
	return create_tween().set_trans(Tween.TRANS_BACK).set_ease(ease)


func _custom_tween_property(
	object: Object,
	property: NodePath,
	final_val: Variant,
	duration: float,
	ease: Tween.EaseType,
) -> PropertyTweener:
	return _create_custom_tween(ease).tween_property(object, property, final_val, duration)
