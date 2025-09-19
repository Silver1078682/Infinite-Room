extends Node

## Library for useful functions about [Array].

const FOUR_DIRECTIONS_2D = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const SIX_DIRECTIONS_3D = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.FORWARD, Vector3i.BACK]


## Returns the sum of an array
static func sum(arr: Array) -> Variant:
	return arr.reduce(func(a, b): return a + b)


## Returns the mean value of an array
static func mean(arr: Array) -> Variant:
	return arr.reduce(func(a, b): return a + b) / float(arr.size())


## Returns a random element and pop it from the original array.
static func pop_rand(arr: Array):
	var idx := randi_range(0, arr.size() - 1)
	return arr.pop_at(idx)


## Drop duplicate elements in an array, using dictionary.
static func unique(arr: Array) -> Array:
	var dict := {}
	for i in arr:
		dict[i] = null
	return dict.keys()


## Count the frequency each element appears in the array, using dictionary.
static func count_all(arr: Array) -> Dictionary:
	var dict := {}
	for i in arr:
		dict[i] = dict.get_or_add(i, 0) + 1
	return dict


## Intersection of two arrays.
static func intersection(a: Array, b: Array) -> Array:
	var dict := {}
	var result := []
	for i in a:
		dict[i] = null
	for i in b:
		if i in dict:
			result.append(i)
	return result


## Returns a random derangement of the [param arr].[br]
## i.e shuffle the array but any element won't stay at its previous position.
static func rand_derange(arr: Array) -> Array:
	var size := arr.size()
	var idx_arr := range(size)
	var result := idx_arr.duplicate()
	idx_arr.shuffle()
	for i in size:
		result[idx_arr[i]] = arr[idx_arr[i - 1]]
	return result


## return a "nested and typed" matrix with any dimension bigger than 2.
## an empty array with the desired type should be passed as [param]typed_arr[/param].
## just pass an untyped array also works.
## [codeblock]
## var arr : Array[int] = []
## var matrix := ArrLib.matrix([2, 2, 6, 3], arr, 0)
## print(matrix[3][6][2][2]) # Prints 0
## [/codeblock]
static func matrix(size: Array, default: Variant, typed_arr: Array = []):
	if size.size() < 2:
		printerr("a matrix must be at least 2 dimensional")
	var one := typed_arr.duplicate()  #type_arr doesn't have to be empty actually, but it's not recommended for performance issue.
	one.resize(size[0])
	one.fill(default)
	var empty: Array[Array] = []
	var larger = empty.duplicate()
	var smaller := one
	for d in range(1, size.size()):
		for j in size[d]:
			larger.append(smaller.duplicate(true))
		smaller = larger
		larger = empty.duplicate()
	return smaller


## same as [func]matrix[/func], but only accept Vector2i as [param]size[/param] and only return 2D matrices.
## to access an element at coordinate (x,y), use matrix[y][x].
static func matrix_2d(size: Vector2i, default: Variant, typed_arr: Array = []) -> Array[Array]:
	var result: Array[Array] = []
	for y in size.y:
		var child := typed_arr.duplicate()
		child.resize(size.x)
		child.fill(default)
		result.append(child)
	return result


static func split(arr: Array, step: int) -> Array:
	var result = []
	for i in range(0, arr.size(), step):
		result.append(arr.slice(i, i + step))
	return result
