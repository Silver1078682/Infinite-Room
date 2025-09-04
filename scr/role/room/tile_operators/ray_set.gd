class_name TileOPRaySet extends TileOP
var _rays: Array[TileOPRay]
var current_ray: int

func _iter_init(_iter: Array) -> bool:
	current_ray = 0
	return not _rays.is_empty()

func _iter_get(_iter: Variant) -> Variant:
	return _rays[current_ray].get_value()

func _iter_next(_iter: Array) -> bool:
	_rays[current_ray].current += 1
	while _rays[current_ray].current >= _rays[current_ray].length:
		current_ray += 1
		if current_ray >= _rays.size():
			return false
	return true
