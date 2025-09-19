extends Node2D

signal door_opened
signal door_closed

@onready var label: Label = $Label


func _ready() -> void:
	_update_sprite()
	


func _input(_event: InputEvent) -> void:
	if World.input("just_pressed", &"enter"):
		if _player_count == 1:  ## replace it in multi-player
			var new_room_theme := RoomManager.predict_next_theme()
			var new_room = RoomManager.create_a_room(new_room_theme)
			RoomManager.enter_room(new_room)


func _update_sprite() -> void:
	pass


func _on_area_2d_body_entered(_body: Node2D) -> void:
	_player_count += 1


func _on_area_2d_body_exited(_body: Node2D) -> void:
	_player_count -= 1


var _player_count := 0:
	set(p_player_count):
		if p_player_count and not _player_count:
			door_opened.emit()
		elif _player_count and not p_player_count:
			door_closed.emit()
		_player_count = p_player_count
