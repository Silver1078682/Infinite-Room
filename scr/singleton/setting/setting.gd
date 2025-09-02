## WIP
class_name Setting
static var debug_mode := true
static var log_dir := "user://logs"
const FONT_SIZE_STEP = 19
static var font_size := 1:
	set(p_size):
		p_size = clampi(p_size, 1, 3)
		update_font_size(p_size)
		font_size = p_size

# This function can go beyond the limit.
static func update_font_size(p_size: int = font_size) -> void:
	for i in 5:
		await Lib.get_tree().process_frame # wait for the tree to fully loaded
	for control: Control in Lib.get_tree().get_nodes_in_group(&"FontResizable"):
		control.add_theme_font_size_override("font_size", p_size * FONT_SIZE_STEP)



static var volume = 100.0


static func get_save():
	return debug_mode


static func mvc_bind(setting_name: StringName, controller: Control, signal_name: StringName):
	var updated: Signal = controller.get(signal_name)
	updated.connect(func(new_value): interface.set(setting_name, new_value))


const _SET_INTERFACE_ATTRIBUTE_ERROR = "The Setting.interface can not be override"
static var interface: Setting:
	set(p):
		if interface:
			assert(false, _SET_INTERFACE_ATTRIBUTE_ERROR)
			Log.warning(_SET_INTERFACE_ATTRIBUTE_ERROR)
	get:
		return _interface

static var _interface := Setting.new()
