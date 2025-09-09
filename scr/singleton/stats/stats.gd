class_name Stats
extends Node


class _BlockData:
	extends RefCounted
	var place_counts := 0
	var mined_counts := 0

	func _to_string() -> String:
		return str({"place_counts": place_counts, "mined_counts": mined_counts})


static var _blocks_stats: Dictionary[String, _BlockData] = {}


static func block(block_name: String) -> _BlockData:
	return _blocks_stats.get_or_add(block_name, _BlockData.new())


class _RoomData:
	extends RefCounted
	var enter_counts := 0
	var stay_total_time := 0

	func _to_string() -> String:
		return str({"enter_counts": enter_counts, "stay_total_time": stay_total_time})


static var _rooms_stats: Dictionary[String, _RoomData] = {}


static func room(room_name: String) -> _RoomData:
	return _rooms_stats.get_or_add(room_name, _RoomData.new())


static func clear() -> void:
	_blocks_stats.clear()
	_rooms_stats.clear()


static func as_text() -> String:
	var text = ""
	for i in _blocks_stats:
		text += i + " : " + str(_blocks_stats[i]) + "\n"
	for i in _rooms_stats:
		text += i + " : " + str(_rooms_stats[i]) + "\n"
	return text
