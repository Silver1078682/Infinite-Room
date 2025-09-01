class_name SettingModifier
extends Node
## MVC component modifying [Setting]
@export var setting_name: StringName
@export var signal_name := &"value_changed"
@export var property_name := &"value"


func _ready() -> void:
	get_parent().set(property_name, Setting.interface.get(setting_name))
	Setting.mvc_bind(setting_name, get_parent(), signal_name)
