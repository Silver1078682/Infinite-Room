class_name Stats
extends Node


class _BlockData:
	extends RefCounted
	var place_counts := 0
	var mined_counts := 0


static var _blocks_stats: Dictionary[String, _BlockData] = {}


static func block(block_name: String) -> _BlockData:
	return _blocks_stats.get_or_add(block_name, _BlockData.new())


class _RoomData:
	extends RefCounted
	var enter_counts := 0
	var stay_total_time := 0


static var _rooms_stats: Dictionary[String, _RoomData] = {}


static func room(room_name: String) -> _RoomData:
	return _rooms_stats.get_or_add(room_name, _RoomData.new())


static func clear():
	_blocks_stats.clear()
	_rooms_stats.clear()
