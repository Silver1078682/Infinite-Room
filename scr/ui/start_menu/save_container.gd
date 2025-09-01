extends PanelContainer
## container holding a game save
@onready var title: Button = %Title
var save_name:
	set(p_save_name):
		if title:
			title.text = p_save_name
		save_name = p_save_name


func set_save(p_save_name: String):
	save_name = p_save_name.trim_suffix(".json")


func _ready():
	title.text = save_name


func delete_this_save() -> void:
	DirAccess.remove_absolute(SL.save_directory_path + SL.SAVE_FILE_SUFFIX % save_name)
	queue_free()
	Log.notice("Save %s deleted" % save_name)
