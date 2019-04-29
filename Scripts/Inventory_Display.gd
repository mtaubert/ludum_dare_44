extends Node2D


func _ready():
	Item_Manager.connect("item_purchased", self, "refresh_inventory")
	Item_Manager.connect("consumable_used", self, "refresh_inventory")
	Game_Manager.connect("encounter_state", self, "update_consumable_usability")
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
	update_consumable_usability(Game_Manager.inEncounter)

func update_consumable_usability(inEncounter):
	var consumables = Item_Manager.get_consumables()
	
	for child in $Consumables.get_children():
		if child.get_index() < consumables.size():
			var usableInCombat = Item_Manager.items[consumables.keys()[child.get_index()]]["encounter_use"]
			
			if usableInCombat == null: #Items usable anytime
				child.disabled = false 
			elif usableInCombat == inEncounter: #Items usable in the current state
				child.disabled = false
			else: #Items currently unusable
				child.disabled = true 