extends TextureButton

func setup(item, amount):
	if item != null:
		$Item.texture = Item_Manager.items[item]["image"]
		$Amount.text = "x" + String(amount)
		visible = true
	else:
		visible = false

func _on_Consumable_Item_pressed():
	pass # Replace with function body.
	#Use the item
