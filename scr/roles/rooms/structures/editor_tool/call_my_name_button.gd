extends Button
@export var func_name := ""
@export var args := []
@export var arg_convert := true
func _ready() -> void:
	pressed.connect(_call)
	func_name = self.name.to_snake_case() if not func_name else func_name
	text = self.name

func _call():
	var current : Node = self
	while current.get_parent():
		if current.has_method(func_name):
			if args:
				current.callv(func_name, _converted_arg() if arg_convert else args)
			else:
				current.call(func_name)
			return
		current = current.get_parent()
	printerr("fail to call %s"% func_name)

func _converted_arg():
	var a = []
	for i in args:
		if i is NodePath:
			var node := get_node_or_null(i)
			if node.get("text") != null:
				a.append(node.text)
			else:
				a.append(node)
		else:
			a.append(i)
	return a
		
			
