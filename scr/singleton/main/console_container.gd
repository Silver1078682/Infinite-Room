extends "res://addons/godot-console/scripts/console_container.gd"


func _init() -> void:
	super()
	_console_output.mouse_filter = MOUSE_FILTER_STOP

	Console.add_command("exit", hide, "Exit the console.")


func _on_exit_pressed() -> void:
	hide()
