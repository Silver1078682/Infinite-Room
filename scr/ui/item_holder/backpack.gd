extends ItemSlotContainer
## Inventory


func _init() -> void:
	Console.add_command("give", _obtain_command)


func _obtain_command(item_name: StringName, amount: int):
	if Item.has_item(item_name):
		pass
	obtain(Item.create(item_name), amount)
