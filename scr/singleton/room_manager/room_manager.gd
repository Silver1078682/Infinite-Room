class_name RoomManager
extends Node

static var _current_room: Room


static func get_current_room():
	return _current_room


static func enter_room(room: Room):
	if _current_room:
		_current_room.exit()
	if room:
		room.enter()
		_current_room = room
