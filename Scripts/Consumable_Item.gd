extends TextureButton

var itemName

func setup(item, amount):
	if item != null:
		$Item.texture = Item_Manager.items[item]["image"]
		$Amount.text = "x" + String(amount)
		mouse_filter = Control.MOUSE_FILTER_STOP
		visible = true
		disabled = false
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = false
		disabled = true
	
	itemName = item

func _on_Consumable_Item_pressed():
	Game_Manager.use_consumable(itemName)
