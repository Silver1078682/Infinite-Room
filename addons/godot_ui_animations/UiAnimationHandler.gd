# MIT License
# Copyright (c) 2025 Rock Gementiza
# NOTE the code has been modified (a lot)
# The codes are intended for Controls, but seemingly applies to all Node2D
extends Node

var default_offset := 8.0
var default_duration := 0.3


func get_node_center(node: CanvasItem) -> Vector2:
	return (get_viewport().get_visible_rect().size / 2) - (node.size / 2)

## Recommended Ease : EaseOut
func slide_from_side(
	node: CanvasItem,
	side: int,
	tween: Tween,
	offset := default_offset,
	duration := default_duration,
):
#region slide from
	match side:
		SIDE_LEFT:
			await slide_from_left(node, tween, offset, duration)
		SIDE_RIGHT:
			await slide_from_right(node, tween, offset, duration)
		SIDE_BOTTOM:
			await slide_from_bottom(node, tween, offset, duration)
		SIDE_TOP:
			await slide_from_top(node, tween, offset, duration)


func slide_from_left(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.position.x = -node.size.x
	await tween.tween_property(node, "position:x", offset, duration).finished


func slide_from_right(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.position.x = get_viewport().size.x
	var vp_size = get_viewport().get_visible_rect().size.x
	var target = (vp_size - node.size.x) - offset
	await tween.tween_property(node, "position:x", target, duration).finished


func slide_from_top(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.position.y = -node.size.y
	await tween.tween_property(node, "position:y", offset, duration).finished


func slide_from_bottom(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.position.y = get_viewport().size.y
	var vp_size = get_viewport().get_visible_rect().size.y
	var target = (vp_size - node.size.y) - offset
	await tween.tween_property(node, "position:y", target, duration).finished


#endregion


## Recommended Ease : EaseIn
func slide_to_side(
	node: CanvasItem,
	side: int,
	tween: Tween,
	offset := default_offset,
	duration := default_duration,
):
#region slide to
	match side:
		SIDE_LEFT:
			await slide_to_left(node, tween, offset, duration)
		SIDE_RIGHT:
			await slide_to_right(node, tween, offset, duration)
		SIDE_BOTTOM:
			await slide_to_bottom(node, tween, offset, duration)
		SIDE_TOP:
			await slide_to_top(node, tween, offset, duration)


func slide_to_left(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", -node.size.x, duration).finished


func slide_to_right(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", get_viewport().size.x, duration).finished


func slide_to_top(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", -node.size.y, duration).finished


func slide_to_bottom(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", get_viewport().size.y, duration).finished


#endregion

## EaseOut
func pop(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.show()
	node.pivot_offset.x = node.size.x / 2 + offset
	node.pivot_offset.y = node.size.y / 2 + offset
	node.scale = Vector2.ZERO

	await tween.tween_property(node, "scale", Vector2.ONE, duration).finished

## EaseIn
func shrink(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.pivot_offset.x = node.size.x / 2 + offset
	node.pivot_offset.y = node.size.y / 2 + offset
	await tween.tween_property(node, "scale", Vector2.ZERO, duration)
	node.hide()

## EaseIn
func fade_in(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.show()
	await tween.tween_property(node, "modulate:a", 1, duration).finished


func from_left_to_center(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", get_node_center(node).x, duration).finished


func from_center_to_left(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", -node.size.x, duration)


func from_right_to_center(node, tween: Tween, offset := default_offset, duration := default_duration):
	node.position.x = get_viewport().get_visible_rect().size.x
	await tween.tween_property(node, "position:x", get_node_center(node).x, duration)


func from_center_to_right(node, tween: Tween, offset := default_offset, duration := default_duration):
	await tween.tween_property(node, "position:x", node.size.x, duration)
