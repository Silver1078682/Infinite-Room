class_name Terrain
extends Resource
@export var block_type: StringName

## This property is ignored if set empty
## The list of blocks to spawn with possibility weights
@export var block_weight_list: Dictionary[StringName, float]

#minimum 
@export var min_value := 2:
	set(p_min_value):
		_curve.min_value = p_min_value
		min_value = p_min_value

@export var max_value := 8:
	set(p_max_value):
		_curve.max_value = p_max_value
		max_value = p_max_value

## maximum allowed value height gap between two sample point [br]
## if [prop max_sample_value_gap] set negative,
## the property act as a ratio, namely, the value returns
## [prop max_sample_value_gap] * (max_value - min_value)[br]
## if [prop max_sample_value_gap] set positive,
## the value will be exactly the [prop max_sample_value_gap] itself[br]
@export var max_sample_value_gap := -0.8:
	get:
		var gap := max_sample_value_gap
		return gap if gap >= 0 else (max_value - min_value) * abs(gap)

@export var min_sample_interval := 8.0
@export var max_sample_interval := 12.0

@export var smooth := true

var _curve := Curve.new()


func get_value(x: int):
	var prev := _curve.sample(x - 1)
	var next := _curve.sample(x + 1)
	var cur := _curve.sample(x)
	if smooth and (prev - cur) * (next - cur) >= 0:
		cur = (prev + next) / 2
	return int(cur)


func set_width(x: int):
	_curve.max_domain = x
	var sample_x := 0.0
	var sample_y := randf_range(min_value, max_value)
	while sample_x < x:
		var sample_y_min := maxf(sample_y - max_sample_value_gap, min_value)
		var sample_y_max := minf(sample_y + max_sample_value_gap, max_value)
		sample_y = randf_range(sample_y_min, sample_y_max)
		_curve.add_point(Vector2(sample_x, sample_y))
		sample_x += randf_range(min_sample_interval, max_sample_interval)
		pass
