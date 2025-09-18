class_name ItemSlotContainer
extends GridContainer
## A kind of container holding items. for instance: Inventory or Chest UI

const ItemSlot = preload("res://scr/ui/component/item_holder/item_slot.gd")
@export var slot_scene: PackedScene

## the selected slot of the ItemSlotContainer
static var selected: ItemSlot:
	set(p_selected):
		if selected:
			selected.deselected()
		if p_selected:
			_idx = p_selected.idx
			p_selected.selected()
		selected = p_selected

static var current_focused: ItemSlotContainer

#don't set this attribute directly
static var _idx: int


# use this instead
static func set_idx(p_idx: int) -> void:
	var child_cnt := current_focused.get_child_count()
	p_idx = clampi(p_idx, 0, child_cnt - 1)
	selected = current_focused.get_child(p_idx)
	_idx = p_idx


## how much item can the [ItemSlotContainer] holds.
@export var volume: int:
	set(p_volume):
		if p_volume <= 0:
			printerr("a volume of a ItemSlotContainer should not be negative")
		volume = maxi(0, p_volume)


#
func _ready() -> void:
	Lib.free_children(self)
	for i in volume:
		var slot: ItemSlot = slot_scene.instantiate()
		slot.idx = i
		add_child.call_deferred(slot)
	#TBD How to handle situatuin whem there'are multiple [ItemSlotContainer]?
	if not selected:
		current_focused = self
		await get_tree().process_frame  # wait till the children is ready
		selected = get_child(0)


#
## Clear the [ItemSlotContainer]
func clear():
	get_children().map(func(child): child.clear())


## Obtain [param item]. the [param amount] should be positive
## Return true if succeed.
func obtain(item: Item, amount := 1) -> bool:
	var empty_slots: Array[ItemSlot] = []
	var left := amount
	for slot: ItemSlot in get_children():
		if slot.amount == 0:
			empty_slots.append(slot)
		elif slot.item == item:
			var add = min(left, item.stack_amount - slot.amount)
			left -= add
			slot.amount += add
			if not left:
				break
	if left and not empty_slots.is_empty():
		for slot: ItemSlot in empty_slots:
			var add = min(left, item.stack_amount)
			left -= add
			slot.item = item
			slot.amount += add
			if not left:
				break
	return left == 0


func count() -> Dictionary[Item, int]:
	var result := {}
	for i: ItemSlot in get_children():
		result[i.item] = i.amount
	return result


## Returns true if the ItemSlotContainer contains the given [param item].
func has(item: Item) -> bool:
	for item_slot in get_children():
		if item_slot.is_item(item):
			return true
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_down", false, true):
		set_idx(_idx + 1)
	if event.is_action_pressed("scroll_up", false, true):
		set_idx(_idx - 1)


#
#
func _to_string():
	return str(get_children())


func get_save() -> Dictionary[String, Variant]:
	return {"content": get_children().map(func(child): return child.get_save())}


func load_save(save: Dictionary) -> void:
	var content = save["content"]
	if content.size() != volume:
		Log.warning("The size of this [ItemSlotContainer] save doesn't match its current volume")
	await Lib.ensure_ready(self)
	await get_tree().process_frame
	for i in min(content.size(), get_children().size()):
		get_child(i).load_save(content[i])
