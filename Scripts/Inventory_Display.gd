extends Node2D

func _ready():
	Item_Manager.connect("item_purchased", self, "refresh_inventory")
	Item_Manager.connect("consumable_used", self, "refresh_inventory")
	refresh_inventory()

func refresh_inventory():
	var items = Item_Manager.get_unique_items()
	var consumables = Item_Manager.get_consumables()
	
	for child in $Items.get_children():
		if child.get_index() < items.size():
			child.setup(items[child.get_index()])
		else:
			child.setup(null)
	
	for child in $Consumables.get_children():
		if child.get_index() < consumables.size():
			child.setup(consumables.keys()[child.get_index()], consumables[consumables.keys()[child.get_index()]])
		else:
			child.setup(null, null)