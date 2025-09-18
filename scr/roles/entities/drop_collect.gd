#class_name DropCollect
extends Area2D
## An area managing collection of drops, typically used for players
## The parent of this Node will collect the drop


func _process(_delta: float) -> void:
	if has_overlapping_bodies():
		for drop: Item.Drop in get_overlapping_bodies():
			collect(drop)


## the default freeze time after a drop is added to the blacklist
## see [func add_to_blacklist]
@export var default_freeze_time := 0.8:
	set(p_default_freeze_time):
		default_freeze_time = maxf(p_default_freeze_time, 0)


## prevent the area the [para drop] from being collected by this [DropCollect] for [para freeze_time]
func add_to_blacklist(drop: Item.Drop, freeze_time: float = default_freeze_time):
	_blacklist[drop] = freeze_time
	get_tree().create_timer(freeze_time).timeout.connect(remove_from_black_list.bind(drop))


## remove the drop from blacklist
func remove_from_black_list(drop: Item.Drop):
	_blacklist.erase(drop)
	if drop in _to_be_handled and not drop.target:
		collect(drop)


## collect a drop, do not guarantee success
func collect(drop: Item.Drop):
	if drop.target or drop in _blacklist:
		return
	if UI.instance.backpack.obtain(drop.item):
		drop.target = get_parent()


func _collect(drop: Item.Drop):
	drop.target = get_parent()


var _to_be_handled: Dictionary[Item.Drop, Object] = {}
var _blacklist: Dictionary[Item.Drop, float] = {}
