class_name UI
extends Control
## NOTE This class only manages UI when a game instance is running
## See [StartMenu] for UI system when no game is running

static var instance: UI

# TODO refer to backpack system in other game
@onready var backpack: ItemSlotContainer = %BackpackPanel/%Backpack


func _init() -> void:
	instance = self


func _input(_event: InputEvent) -> void:
	if _event.is_action_released("toggle_ui"):
		visible = !visible
		return

	if _event.is_action_released("show_console"):
		if not %ConsoleContainer.visible:
			%ConsoleContainer.show()
