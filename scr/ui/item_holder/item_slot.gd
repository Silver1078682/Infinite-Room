extends PanelContainer
@onready var texture: TextureRect = %Texture
@onready var label: Label = %Label

## Item it holds
var item: Item:
	set(p_item):
		texture.texture = p_item.texture if p_item else null
		item = p_item

## How much items it holds
var amount: int:
	set(p_amount):
		label.text = str(p_amount)
		if not p_amount:
			item = null
			label.text = ""
		amount = p_amount

## What position the slot is in the ItemSlotContainerContainer
var idx: int

#
# Selected when clicked
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
			ItemSlotContainer.selected = self

#
func deselected():
	%Select.hide()

func selected():
	%Select.show()

#
#
func _to_string() -> String:
	return str(item) + str(amount)

#
#
func get_save() -> Dictionary[String, Variant]:
	return {
		"item": item.name if item else "",
		"amount": amount,
	}

func load_save(save: Dictionary) -> void:
	var p_item := Item.create(save["item"])
	SL.load_to_node(self, save)
	item = p_item
