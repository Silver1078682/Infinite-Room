class_name Stats
extends Node
## Statistics for game content


## get the statistics data of a block, return a [Stats._BlockData]
static func block(block_name: String) -> _BlockData:
	return _blocks_stats.get_or_add(block_name, _BlockData.new())


## get the statistics data of a [RoomTheme], return a [Stats._RoomData]
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


static func get_save() -> Dictionary:
	var block_save := {}
	for i in _blocks_stats:
		block_save[i] = _blocks_stats[i].to_dict()

	var room_save := {}
	for i in _rooms_stats:
		room_save[i] = _rooms_stats[i].to_dict()

	return {"block": block_save, "room": room_save}


static func load_save(save: Dictionary) -> void:
	for i in save["block"]:
		_blocks_stats[i] = _BlockData.from_dict(save["block"][i])
	for i in save["room"]:
		_rooms_stats[i] = _RoomData.from_dict(save["room"][i])



class _BlockData:
	extends RefCounted
	var place_counts := 0
	var mined_counts := 0

	func _to_string() -> String:
		return str(to_dict())

	func to_dict() -> Dictionary:
		return {"place_counts": place_counts, "mined_counts": mined_counts}

	static func from_dict(dict: Dictionary) -> _BlockData:
		var data = _BlockData.new()
		data.place_counts = dict["place_counts"]
		data.mined_counts = dict["mined_counts"]
		return data


static var _blocks_stats: Dictionary[String, _BlockData] = {}


class _RoomData:
	extends RefCounted
	var enter_counts := 0
	var stay_total_time := 0

	func _to_string() -> String:
		return str(to_dict())

	func to_dict() -> Dictionary:
		return {"enter_counts": enter_counts, "stay_total_time": stay_total_time}

	static func from_dict(dict: Dictionary) -> _RoomData:
		var data = _RoomData.new()
		data.enter_counts = dict["enter_counts"]
		data.stay_total_time = dict["stay_total_time"]
		return data


static var _rooms_stats: Dictionary[String, _RoomData] = {}
