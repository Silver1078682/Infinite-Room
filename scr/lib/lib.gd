extends Node

const Arr = preload("res://scr/lib/arr_lib.gd")
const Dict = preload("res://scr/lib/dict_lib.gd")
const Rand = preload("res://scr/lib/rand_lib.gd")
const ImageUtil = preload("res://scr/lib/image_lib.gd")
const Warning = preload("res://scr/lib/warning_lib.gd")

## Wait [para time] seconds, use await before the function
func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout


## Drops the null value of an array
func drop_null(arr: Array) -> Array:
	return arr.filter(func(variant): return variant != null)


## Returns the sum of an array
func sum(arr: Array) -> Variant:
	return arr.reduce(func(a, b): return a + b)


## Returns a callable according to the operator given
func op(operator: Variant.Operator) -> Callable:
	match operator:
		OP_ADD:
			return func(a,b) : return a + b
		OP_AND:
			return func(a,b) : return a and b
		OP_BIT_AND:
			return func(a,b) : return a & b
		OP_BIT_NEGATE:
			return func(a) : return ~ a
		OP_BIT_OR:
			return func(a,b) : return a | b
		OP_BIT_XOR:
			return func(a,b) : return a ^ b
		OP_DIVIDE:
			return func(a,b) : return a / b
		OP_DIVIDE:
			return func(a,b) : return a / b
		OP_EQUAL:
			return func(a,b) : return a == b
		OP_GREATER:
			return func(a,b) : return a > b
		OP_GREATER_EQUAL:
			return func(a,b) : return a >= b
		OP_IN:
			return func(a,b) : return a in b
		OP_LESS:
			return func(a,b) : return a < b
		OP_LESS_EQUAL:
			return func(a,b) : return a <= b
		OP_MODULE:
			return func(a,b) : return a % b
		OP_MULTIPLY:
			return func(a,b) : return a * b
		OP_NEGATE:
			return func(a) : return - a
		OP_NOT:
			return func(a) : return not a
		OP_NOT_EQUAL:
			return func(a,b) : return a != b
		OP_OR:
			return func(a,b) : return a or b
		OP_POSITIVE:
			return func(a) : return + a
		OP_POWER:
			return func(a,b) : return a ** b
		OP_SHIFT_LEFT:
			return func(a,b) : return a << b
		OP_SHIFT_RIGHT:
			return func(a,b) : return a >> b
		OP_SUBTRACT:
			return func(a,b) : return a - b
		OP_XOR:
			push_error("Logical XOR operator is not implemented in GDScript.")
			return func(): return
		_:
			push_error("invalid operator.")
			return func(): return


## Queue free all children of the [param node]
func free_children(node: Node) -> void:
	for child: Node in node.get_children():
		child.queue_free()

func ensure_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready

func only_show_latter(prev: Control, next: Control) -> void:
	if prev:
		prev.hide()
	if next:
		next.show()

signal scene_changed
func change_scene_to(path: String):
	scene_changed.emit()
	get_tree().change_scene_to_file(path)


class Iterator:
	extends RefCounted
	var start
	var cnt
	var step
	var _cur = 0
	var _cnt = 0

	func _init(p_start, p_cnt, p_step) -> void:
		start = p_start
		cnt = p_cnt
		step = p_step

	func _iter_init(_iter: Array) -> bool:
		_cur = start
		_cnt = 0
		return _cnt < cnt

	func _iter_next(_iter: Array) -> bool:
		_cur += step
		_cnt += 1
		return _cnt < cnt

	func _iter_get(_iter: Variant) -> Variant:
		return _cur
