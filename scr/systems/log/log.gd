class_name Log


enum DebugLevel {
	#
	DEBUG,  #最详细的日志信息，典型应用场景是 问题诊断
	INFO,  # 信息详细程度仅次于DEBUG，通常只记录关键节点信息，用于确认一切都是按照我们预期的那样进行工作
	NOTICE,  # 提示用户信息
	WARNING,  # 当某些不期望的事情发生时记录的信息（如，磁盘可用空间较低），但是此时应用程序还是正常运行的
	ERROR,  # 由于一个更严重的问题导致某些功能不能正常运行时记录的信息
	_CRITICAL,
	_ALERT,
	_EMERGENCY
}

static var _file: FileAccess
static var file_path: String
static var _level := DebugLevel.INFO


#---------------------------------------------------------------------------------------------------
static func _static_init() -> void:
	const DEFAULT_FOLDER_PATH: String = "user://logs"
	var folder = DEFAULT_FOLDER_PATH
	DirAccess.make_dir_recursive_absolute(folder)
	file_path = folder.path_join("%s.txt") % Time.get_date_string_from_system()
	set_file_path(file_path)
	
	# override default Lib.Warning function with Log function
	Lib.Warning.info = info
	Lib.Warning.error = error
	Lib.Warning.warning = warning


#---------------------------------------------------------------------------------------------------
static func set_file_path(value: String):
	file_path = ProjectSettings.globalize_path(value)
	if not FileAccess.file_exists(file_path):
		FileAccess.open(file_path, FileAccess.WRITE).close()


#---------------------------------------------------------------------------------------------------
static func _process(_delta):
	return
	#if _file and _file.is_open():
	#_file.close()
	## Why this lines exists?


#---------------------------------------------------------------------------------------------------
static func set_level(value: DebugLevel):
	_level = value


#---------------------------------------------------------------------------------------------------
static func write_entry(entry: Entry) -> void:
	if entry.level < _level:
		return
	_godot_print(entry)
	_simple_write("\n" + entry.to_string())


#---------------------------------------------------------------------------------------------------
static func debug(message: Variant) -> void:
	# 调试
	write_entry(Entry.new(str(message), DebugLevel.DEBUG))


#---------------------------------------------------------------------------------------------------
static func info(message: Variant) -> void:
	# 常规
	write_entry(Entry.new(str(message), DebugLevel.INFO))


#---------------------------------------------------------------------------------------------------
static func notice(message: Variant) -> void:
	# 消息
	write_entry(Entry.new(str(message), DebugLevel.NOTICE))


#---------------------------------------------------------------------------------------------------
static func warning(message: Variant) -> void:
	# 警告
	write_entry(Entry.new(str(message), DebugLevel.WARNING))


#---------------------------------------------------------------------------------------------------
static func error(message: Variant) -> void:
	# 错误
	write_entry(Entry.new(str(message), DebugLevel.ERROR))
	_simple_write(_get_stack_string())


#---------------------------------------------------------------------------------------------------
static func _simple_write(text: String):
	if not _file or not _file.is_open():
		_file = FileAccess.open(file_path, FileAccess.READ_WRITE)
		_file.seek(_file.get_length())
		_file.store_string(text)


#---------------------------------------------------------------------------------------------------
static func _get_stack_string():
	var result = ""
	var stacks = get_stack()
	stacks.pop_front()
	for data in stacks:
		result += "\n\t"
		for key in data:
			result += "||  %s : %s  " % [key, str(data[key])]
	return result


#---------------------------------------------------------------------------------------------------
static func _godot_print(entry: Entry) -> void:
	var text = entry.to_string()
	match entry.level:
		DebugLevel.INFO:
			print(text)
		DebugLevel.NOTICE:
			print_rich("[color=green]%s[/color]" % text)
		DebugLevel.WARNING:
			print_rich("[color=yellow]%s[/color]" % text)
			push_warning(text)
		DebugLevel.ERROR:
			print_rich("[color=red]%s[/color]" % text)
			push_error(text)


#---------------------------------------------------------------------------------------------------
class Entry:
	var message: String
	var timestamp: Dictionary:
		get:
			return timestamp.duplicate()
	var level: DebugLevel

	func _init(p_message: String, p_level: DebugLevel) -> void:
		message = p_message
		level = p_level
		timestamp = Time.get_datetime_dict_from_system()

	func _to_string() -> String:
		return "[%s] at %d:%d:%d | %s" % [Entry._level_to_string(level), timestamp["hour"], timestamp["minute"], timestamp["second"], message]

	static func _level_to_string(_level: DebugLevel) -> String:
		match _level:
			DebugLevel.DEBUG:
				return "Debug"
			DebugLevel.INFO:
				return "Info"
			DebugLevel.NOTICE:
				return "Notice"
			DebugLevel.WARNING:
				return "Warning"
			DebugLevel.ERROR:
				return "Error"
			_:
				return ""


# MIT License

# Copyright (c) 2025 JACKADUX

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
