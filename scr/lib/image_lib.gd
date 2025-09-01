class_name IMGHelper
extends Object
## Library for handling image.
#quite useless actually.


static func average(img: Image, ignore_alpha = true) -> Color:
	var sample := Color()
	var width := img.get_width()
	var height := img.get_height()
	for x in range(width):
		for y in range(height):
			var color := img.get_pixel(x, y)
			if ignore_alpha and color.a == 0:
				continue
			sample += img.get_pixel(x, y)
	return sample / (width * height)


static func colors(img: Image) -> PackedColorArray:
	var ans: PackedColorArray = []
	var width := img.get_width()
	var height := img.get_height()
	for x in range(width):
		for y in range(height):
			ans.append(img.get_pixel(x, y))
	return ans




static func scale(img: Image, scale_factor: Vector2, interpolation: Image.Interpolation) -> void:
	img.resize(img.get_width() * scale_factor.x, img.get_height() * scale_factor.y, interpolation)
	pass
