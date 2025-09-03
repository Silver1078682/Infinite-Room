extends Node


## Returns a random Vector2 in a rect2
static func rect2(rect: Rect2) -> Vector2:
	return Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))


## Returns a random Vector2i in a rect2i
static func rect2i(rect: Rect2i) -> Vector2i:
	return Vector2i(randi_range(rect.position.x, rect.end.x), randi_range(rect.position.y, rect.end.y))


## Returns a random child of [param node]
static func child_of(node: Node) -> Node:
	return node.get_children().pick_random()


## Returns a random element of [param obj], [param obj] can be a [String], a [Stringname], or an [Array]
static func element(obj: Variant) -> Variant:
	return obj[randi_range(0, len(obj) - 1)]


## Returns a random element between [param a] and [param b].
static func between(a: Variant, b: Variant) -> Variant:
	return lerp(a, b, randf())


## Returns a random point in a circle.
## The result is uniform.
static func circle(center := Vector2.ZERO, radius := 1.0) -> Vector2:
	var theta := randf() * TAU
	var r := sqrt(randf()) * radius
	return Vector2(cos(theta) * r, sin(theta) * r) + center


## Returns a random point in a triangle.
## It's vertex are [param a], [param b] and [param c].
## The result is uniform.
static func triangle(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	var wb = randf()
	var wc = randf()
	if (wb + wc) > 1:
		wb = 1 - wb
		wc = 1 - wc

	var rb = wb * (b - a)
	var rc = wc * (c - a)

	return rb + rc + a


#原作者：bm小生
#链接：https://juejin.cn/post/7210945608877834295


## Returns a string containing only characters from [param chars]
## [codeblock]
## var password := Rand.string(10, "1234567890qwertyuiopasdfghjkklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM")
## [/codeblock]
static func string(length := 10, chars = "1234567890") -> String:
	var result := ""
	for i in length:
		result += chars[randi_range(0, len(chars) - 1)]
	return result


## Returns a Shuffle Bag.[br]
## A Shuffle Bag is a technique for controlling randomness to create the distribution we desire.[br]
## The idea is: Pick a range of values with the desired distribution.[br]
## Put all these values into a bag. [br]
## Shuffle the bag. [br]
## Pick elements from the bag in order. [br]
## When we ends up an empty bag, refill it. [br]
## [codeblock]
## var super_tree = Rand.shuffle_bag(["apple", "banana", "peach"])
##
## for i in 2:
##     var fruit = super_tree.next()    # use next method to get next element
##     print(fruit)
## #banana
## #apple
##
## super_tree.refill()                  # manually reinitiate the shuffle bag
## for fruit in super_tree:             # Use iterator to get elements, end the loop when there's no element left
##     print(fruit)
## #apple
## #peach
## #banana
## [/codeblock]
static func shuffle_bag(_items: Array) -> ShuffleBag:
	var bag = ShuffleBag.new()
	bag._items = _items
	return bag


## Shuffle bag
class ShuffleBag:
	extends RefCounted
	var _items := []
	var _left := []

	func refill() -> void:
		_left = _items.duplicate()
		_left.shuffle()

	func next() -> Variant:
		if _left.is_empty():
			refill()
		return _left.pop_back()

	func _iter_init(_iter):
		return not _left.is_empty()

	func _iter_next(_iter):
		return not _left.is_empty()

	func _iter_get(_iter):
		return _left.pop_back()


## Returns a Weighted Random Sampler based on binary search.
## Used for single sampling with replacement.[br]
## The [param dict] should look like {item: weight}[br]
## Call [method assign] on it to reload a dictionary.
## Call [method pick] on it to get the an item.[br]
static func bs_wrs(dict: Dictionary) -> BinarySearchWRS:
	var rng = BinarySearchWRS.new()
	rng.assign(dict)
	return rng


## Binary Search Weighted Random Sampling
class BinarySearchWRS:
	extends RefCounted
	var _items: Dictionary
	var _search_arr := []
	var _left := 0
	var _right := 0

	func assign(dict: Dictionary) -> void:
		_items = dict
		_search_arr = [0]

		for key in dict:
			_search_arr.append(_search_arr[-1] + dict[key])

	func pick() -> Variant:
		_left = 0
		_right = _search_arr.size()
		var rand := randf_range(0, _search_arr[-1])
		return _search(rand)

	func _search(rand: float) -> Variant:
		if abs(_left - _right) <= 1:
			return _items.keys()[_left]
		var idx = (_left + _right) / 2
		if _search_arr[idx] < rand:
			_left = idx
		else:
			_right = idx
		return _search(rand)


## Returns a Weighted Random Sampler based on A Res.
## Used for multiple sampling without replacement.[br]
## The [param dict] should look like {item: weight}[br]
## Call [method assign] on it to reload a dictionary.
## Call [method pick] on it to get the an item.[br]
static func ares_wrs(dict: Dictionary) -> AResWRS:
	var rng := AResWRS.new()
	rng.assign(dict)
	return rng


## A Res Weighted Random Sampling
class AResWRS:
	extends RefCounted
	var _items: Dictionary

	func assign(dict: Dictionary):
		_items = dict
	
	func get_left_items() -> Dictionary:
		return _items.duplicate()
	
	func pop(count := 1) -> Array:
		var pool := _calc_eigen_value()
		var keys := pool.keys()
		keys.sort_custom(func(x, y): return pool[x] > pool[y])
		return keys.slice(0, count)

	func _calc_eigen_value() -> Dictionary:
		var pool := {}
		for key in _items:
			var weight: float = _items[key]
			var eigen := pow(randf(), 1 / weight)
			pool[key] = eigen
		return pool


## Returns a Weighted Random Sampler based on alias algorithm.
## Used for multiple sampling with replacement.[br]
## The [param dict] should look like {item: weight}[br]
## Call [method assign] on it to reload a dictionary.
## Call [method pick] on it to get the an item.[br]
static func alias_wrs(dict: Dictionary) -> AliasWRS:
	var rng := AliasWRS.new()
	rng.assign(dict)
	return rng


## Alias Weighted Random Sampling
class AliasWRS:
	extends RefCounted
	var _items: Dictionary
	var alias_table: Array[Array] = []
	var _small: Array[Array] = []
	var _large: Array[Array] = []

	func assign(dict: Dictionary) -> void:
		_items = dict
		_init_queue()
		_construct_alias_table()

	func pick() -> Variant:
		var area: Array = alias_table.pick_random()
		var rand := randf()
		if rand < area[0][1]:
			return area[0][0]
		else:
			return area[1][0]

	func _init_queue():
		var sum: float = _items.values().reduce(func(a, b): return a + b)
		var total := _items.size()
		for key in _items:
			var weight: float = _items[key]
			var area := weight / sum * total
			if area > 1:
				_large.append([key, area])
			else:
				_small.append([key, area])

	func _construct_alias_table():
		while _small and _large:
			var large_info: Array = _large.pop_back()
			var little_info: Array = _small.pop_back()
			var restArea: float = large_info[1] - (1 - little_info[1])
			alias_table.append([[large_info[0], 1 - little_info[1]], little_info])
			if restArea > 1:
				_large.append([large_info[0], restArea])
			else:
				_small.append([large_info[0], restArea])
		alias_table.append(_large if _large else _small)
