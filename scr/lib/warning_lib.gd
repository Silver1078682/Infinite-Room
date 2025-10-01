extends Node
## A library of common warnings

static var info = print
static var error = printerr
static var warning = push_warning

const _TRY_ASSIGN = "Trying to assign the "


##[code block]
## var a:
##     set(p):
##         Lib.Warning.read_only("a", p)
## a = 10  ## push a warning: Trying to assign the read-only property a with 10
##[\code block]
static func read_only(prop_name: String, value = "") -> void:
	var suffix := (" with value %s " % value) if value else ""
	warning.call(_TRY_ASSIGN + "read-only property %s" % prop_name + suffix)


##[code block]
## var weight:
##     set(p):
##         weight = Lib.Warning.no_negative("weight", p)
## weight = 10  # This works fine
## weight = -10 # push a warning: Trying to assign the property weight with negative value -10
##[\code block]
static func no_negative(prop_name: String, value = "") -> int:
	if value < 0:
		warning.call(_TRY_ASSIGN + "property %s with a negative value %s" % [prop_name, value])
		return 0
	else:
		return value


static func in_range(prop_name: String, min, max, value = "") -> int:
	const NOT_IN_RANGE := ", which is not in excepted range from %s to %s"
	const WARNING_STR := _TRY_ASSIGN + "property %s with value %s" + NOT_IN_RANGE
	if value < min:
		warning.call(WARNING_STR % [prop_name, value, min, max])
		return min
	elif value > max:
		warning.call(WARNING_STR % [prop_name, value, min, max])
		return max
	else:
		return value


static func does_not_exist(object_name := "", type := "") -> void:
	warning.call("The " + (type if type else "object") + " named %s does not exist" % object_name)


static func try(err: Error) -> bool:
	if err == OK:
		return false
	else:
		warning.call(error_string(err))
		return true
