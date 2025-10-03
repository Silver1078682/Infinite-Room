## WIP
class_name Setting
## Setting of the game.
# TODO
# We need to move these stuffs to a config file.

## the location where setting config is at
const SETTING_PATH := "user://setting.cfg"
const try = Lib.Warning.try  # a macro


static func _static_init() -> void:
	_working_section = "Game"
	_add_setting_property("intervals_between_autosave", 30)

	_working_section = "Other"
	_add_setting_property("log_folder", "user://logs")
	load_config_file()


## set setting named [para name] in [para section] to [para value].
## save the setting to config file immediately if [para save] is set true.
static func set_setting(section: String, name: String, value: Variant, save := true):
	_settings_list[section][name].value = value
	if save:
		save_setting(section, name, value)


## make sure the setting named [para name] in [para section] is saved to the config file.
static func save_setting(section: String, name: String, value: Variant):
	config_file.set_value(section, name, _settings_list[section][name].value)
	config_file.save(SETTING_PATH)


## restore setting named [para name] in [para section] to its default value.
## save the setting to config file immediately if [para save] is set true.
static func restore_setting(section: String, name: String, save := true):
	var property: SettingProperty = _settings_list[section][name]
	property.value = property.default_value
	config_file.save(SETTING_PATH)


## get setting named [para name] in [para section].
static func get_setting(section: String, name: String) -> Variant:
	var property: SettingProperty = _settings_list[section][name]
	assert(property)
	return property.value


## The dictionary of setting
static var _settings_list: Dictionary[String, Dictionary]

## serialized file of the setting
static var config_file: ConfigFile


static func load_config_file() -> bool:
	config_file = ConfigFile.new()
	Lib.simple_open_file(SETTING_PATH, FileAccess.WRITE)
	if not try.call(config_file.load(SETTING_PATH)):
		Log.error("Failed to find the Setting file")
		return false

	for section in _settings_list:
		for name in _settings_list[section]:
			var value = config_file.get_value(section, name, null)
			var property: SettingProperty = _settings_list[section][name]
			## create the value if it does not exist.
			if value == null:
				save_setting(section, name, property.default_value)
			property.value = value
	return true


class SettingProperty:
	extends RefCounted
	var default_value: Variant
	var value: Variant
	var type: Variant.Type
	var descrip: Variant.Type


static var _working_section: String

const SETTING_JSON_PATH = "res://scr/systems/setting/default.json"


## Add all settings declared in a json file whose location is [para file_path].
## See "res://scr/systems/setting/default.json" as a sample template.
static func _add_setting_property_list_from_json(file_path: String) -> void:
	var json_file = Lib.simple_open_file(file_path, FileAccess.READ)
	var setting = JSON.parse_string(json_file.get_as_text())
	if setting == null or setting is not Dictionary:
		Log.error("can not parse the setting json file at " + file_path + " normally")

	for section_name in setting:
		var section = setting[section_name]
		if section is not Dictionary:
			Log.warning("a section must be a dictionary holding setting configs, skipping section " + section)
		for name in section:
			var setting_property = section[name]
			if setting_property is not Dictionary:
				Log.warning("a setting config must be a dictionary, skipping section " + section)
				continue
			var default_value = (setting_property as Dictionary).get("default")
			if not default_value:
				Log.error("a setting must has at least one default value")
			_add_setting_property(name, default_value)


static func _add_setting_property(name: String, default_value: Variant, type: int = -1, section := _working_section) -> SettingProperty:
	var property = SettingProperty.new()
	property.default_value = default_value
	property.type = typeof(default_value) if type == -1 else type
	var section_dict: Dictionary = _settings_list.get_or_add(section, {})
	section_dict[name] = property
	return property

###
#const FONT_SIZE_STEP = 19
#var font_size := 1:
#set(p_size):
#p_size = clampi(p_size, 1, 3)
#update_font_size(p_size)
#font_size = p_size
#
#
## This function can go beyond the font size limit.
#func update_font_size(p_size: int = font_size) -> void:
#for i in 5:
#await Lib.get_tree().process_frame  # wait for the tree to fully loaded
#for control: Control in Lib.get_tree().get_nodes_in_group(&"FontResizable"):
#control.add_theme_font_size_override("font_size", p_size * FONT_SIZE_STEP)
#
#
#var auto_save_time_interval := 30.0
#
### game_volume
#var volume = 100.0

#
### bind a mvc component
#static func mvc_bind(setting_name: StringName, controller: Control, signal_name: StringName):
#var updated: Signal = controller.get(signal_name)
#updated.connect(func(new_value): interface.set(setting_name, new_value))
#updated.connect(func(_new_value): save_setting(setting_name))

#
#static var interface := Setting.new():
#set(p):
#Lib.Warning.read_only("interface on Setting")
