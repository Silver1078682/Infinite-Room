extends Button
var func_name := ""
func _ready() -> void:
	pressed.connect(_call)
	func_name = self.name.to_snake_case() if not func_name else func_name
	text = self.name

func _call():
	var current : Node = self
	while current.get_parent():
		if current.has_method(func_name):
			current.call(func_name)
			return
		current = current.get_parent()
	printerr("fail to call %s"% func_name)
