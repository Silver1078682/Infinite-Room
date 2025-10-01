# Copyright (c) 2020-2025 Mansur Isaev and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
# NOTE the code has been modified

## ConsoleNode class.
##
## By default used as a Singleton. To create a new console command, use [method create_command].
##
## It is advised to call [method create_command] in _static_func
## A callable used as command should be named as _command_* as a convention 

class_name Console
extends Node

## Emitted when the console prints a string.
signal printed_line(string: String)
## Emitted when the console history is cleared.
signal cleared

static var instance: Console

static var _commands: Dictionary[StringName, Dictionary] = {}
static var _command_list: PackedStringArray = PackedStringArray()

static var _history: PackedStringArray
static var _history_index: int


static func _init() -> void:
	add_command("clear", clear, "Clear the console history.")
	add_command("help", _command_help, "Show all console command.")
	add_command("echo", print, "Print a string.")


## Return [param true] if the console has a command.
static func has_command(command: StringName) -> bool:
	return _commands.has(command)


## Return [param true] if command name is valid.
static func is_valid_name(command: StringName) -> bool:
	return command.is_valid_ascii_identifier()


## Remove a command from the console.
static func remove_command(command: StringName) -> void:
	if _commands.erase(command):
		_command_list.clear()


## Return command description.
static func get_command_description(command: StringName) -> String:
	return _commands[command][&"description"] if _commands.has(command) else ""


## Adding a command, won't raise an error if the command exists.
static func add_command(command_name: StringName, callable: Callable, description: String = "") -> void:
	if has_command(command_name):
		remove_command(command_name)
	create_command(command_name, callable, description)


## Create and add a new console command. Use add command instead.
static func create_command(command_name: StringName, callable: Callable, description: String = "") -> void:
	assert(not has_command(command_name), "Command '%s' already exists." % command_name)
	assert(is_valid_name(command_name), "Invalid command name: '%s'." % command_name)
	assert(callable.is_valid(), "Invalid Callable for command '%s'." % command_name)
	assert(callable.is_standard(), "Custom Callable is not supported.")

	var method_info: Dictionary = object_find_method_info(callable.get_object(), callable.get_method())
	assert(method_info, "Method '%s' not found for command '%s'." % [callable.get_method(), command_name])
	assert(is_valid_args(method_info.args), "Unsupported argument types in method '%s'." % callable.get_method())

	var arg_names: PackedStringArray = PackedStringArray()
	var arg_types: PackedInt32Array = PackedInt32Array()
	init_arg_types_and_names(method_info.args, arg_types, arg_names)

	var command: Dictionary[StringName, Variant] = {
		&"name": command_name,
		&"object_id": callable.get_object_id(),
		&"method": callable.get_method(),
		&"description": description,
		&"arg_types": arg_types,
		&"arg_names": arg_names,
		&"default_args": method_info.default_args,
	}
	command.make_read_only()

	_commands[command_name] = command
	_command_list.clear()


## Print string to the console.
static func print(string: String) -> void:
	instance.printed_line.emit(string + "\n")


## Print warning message to the console.
static func warning(string: String) -> void:
	instance.printed_line.emit("[color=YELLOW]" + string + "[/color]\n")


## Print error message to the console.
static func error(string: String) -> void:
	instance.printed_line.emit("[color=RED]" + string + "[/color]\n")


static func validate_argument_count(args: PackedStringArray, cmd: Dictionary) -> bool:
	var expected_max: int = len(cmd.arg_types)
	var expected_min: int = expected_max - len(cmd.default_args)

	if args.size() < expected_min or args.size() > expected_max:
		var error_message: String = ""
		if cmd.default_args:
			error_message = "Invalid argument count: Expected between %d and %d, received %d." % [expected_min, expected_max, args.size()]
		else:
			error_message = "Invalid argument count: Expected %d, received %d." % [expected_max, args.size()]

		error(error_message)
		return false

	return true


## Execute command. First word must be a command name, other is arguments.
static func execute(string: String) -> void:
	var args: PackedStringArray = string.split(" ", false)
	if args.is_empty():
		return

	_history.push_back(string)
	_history_index = _history.size()

	print("[color=GRAY]> " + string + "[/color]")

	if not has_command(args[0]):
		return error("Command '%s' not found." % string)

	var cmd: Dictionary = _commands[args[0]]
	if not is_instance_id_valid(cmd.object_id):
		return error("Invalid object instance.")

	args.remove_at(0)  # Remove command name from arguments.
	if not validate_argument_count(args, cmd):
		return

	var result: Variant = null
	if cmd.arg_types:  # If command has arguments.
		var arg_array: Array = []
		arg_array.resize(args.size())

		for i: int in args.size():
			var value: Variant = convert_string(args[i], cmd.arg_types[i])
			if value == null:
				return error("Invalid argument type: Cannot convert argument %d from 'String' to '%s'." % [i, type_string(cmd.arg_types[i])])

			arg_array[i] = value

		result = instance_from_id(cmd.object_id).callv(cmd.method, arg_array)
	else:
		result = instance_from_id(cmd.object_id).call(cmd.method)

	if result is String:
		print(result)


## Return the previously entered command.
static func get_prev_command() -> String:
	_history_index = wrapi(_history_index - 1, 0, _history.size())
	return "" if _history.is_empty() else _history[_history_index]


## Return the next entered command.
static func get_next_command() -> String:
	_history_index = wrapi(_history_index + 1, 0, _history.size())
	return "" if _history.is_empty() else _history[_history_index]


## Return a list of all commands.
static func get_command_list() -> PackedStringArray:
	if _command_list.is_empty():  # Lazy initialization.
		_command_list = _commands.keys()
		_command_list.sort()

	return _command_list


## Return autocomplete command.
static func autocomplete_command(string: String, selected_index: int = -1) -> String:
	if string.is_empty():
		return string

	var i: int = 0
	for cmd: String in get_command_list():
		if not cmd.begins_with(string):
			continue
		elif i == selected_index:
			return cmd + " "  # A space at the end of a line for convenience.

		i += 1

	return string


## Return a list of autocomplete commands.
static func autocomplete_list(string: String, selected_index: int = -1) -> PackedStringArray:
	var list := PackedStringArray()
	if string.is_empty():
		return list

	var i: int = 0
	for cmd: String in get_command_list():
		if not cmd.begins_with(string):
			continue
		elif i == selected_index:
			list.push_back("[u]" + cmd + "[/u]")
		else:
			list.push_back(cmd)

		i += 1

	return list


## Clear the console history.
static func clear() -> void:
	_history.clear()
	_history_index = 0

	instance.cleared.emit()


static func _command_help() -> void:
	const TEMPLATE: String = "[cell][color=WHITE][url={0} ]{0}[/url][/color][/cell][cell][color=GRAY]{1}[/color][/cell]"

	var output: String = "[table=2]"

	for cmd: String in get_command_list():
		output += TEMPLATE.format([cmd, get_command_description(cmd)])

	print(output + "[/table]")


## Checks if the argument type is supported.
static func is_arg_type_supported(arg_type: int) -> bool:
	const SUPPORTED_TYPES: PackedInt32Array = [
		TYPE_NIL,
		TYPE_BOOL,
		TYPE_INT,
		TYPE_FLOAT,
		TYPE_STRING,
		TYPE_STRING_NAME,
	]

	return arg_type in SUPPORTED_TYPES


## Checks if all arguments are valid.
static func is_valid_args(args: Array[Dictionary]) -> bool:
	for arg: Dictionary in args:
		if not is_arg_type_supported(arg.type):
			return false

	return true


## Finds method info about the method of an object.
static func object_find_method_info(object: Object, method_name: String) -> Dictionary:
	var script: Script = object if object is Script else object.get_script()
	if is_instance_valid(script):
		for method: Dictionary in script.get_script_method_list():
			if method_name == method.name:
				return method

	for method: Dictionary in object.get_method_list():
		if method_name == method.name:
			return method

	return {}


## Initializes argument types and names.
static func init_arg_types_and_names(args: Array[Dictionary], types: PackedInt32Array, names: PackedStringArray) -> void:
	types.resize(args.size())
	names.resize(args.size())

	for i: int in args.size():
		types[i] = args[i][&"type"]
		names[i] = args[i][&"name"] if args[i][&"name"] else "arg%d" % i


## Converts a string to the specified type.
static func convert_string(string: String, type: int) -> Variant:
	if type == TYPE_NIL or type == TYPE_STRING or type == TYPE_STRING_NAME:
		return string  # Non static argument or String/StringName return without changes.
	elif type == TYPE_BOOL:
		if string in [&"true", &"on", &"1"]:
			return true
		elif string in [&"false", &"off", &"0"]:
			return false
		elif string.is_valid_int():
			return string.to_int()
	elif type == TYPE_INT and string.is_valid_int():
		return string.to_int()
	elif type == TYPE_FLOAT and string.is_valid_float():
		return string.to_float()

	return null
