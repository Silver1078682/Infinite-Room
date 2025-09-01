extends Object


func count(iterator) -> Dictionary[Variant, int]:
	var result: Dictionary[Variant, int] = {}
	for i in iterator:
		if i in result:
			result[i] += 1
		else:
			result[i] = 1
	return result


func sum(a: Dictionary, b: Dictionary) -> Dictionary:
	var result := {}
	for i in a:
		result[i] = a[i] + b[i] if (i in b) else 0
	for i in b:
		if i in a:
			continue
		result[i] = b[i]
	return result
