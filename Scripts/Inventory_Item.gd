extends TextureRect

signal tooltip(name_out)
var itemName = ""

func setup(item):
	if item != null:
		$Item.texture = Item_Manager.items[item]["image"]
		visible = true
		itemName = item
	else:
		visible = false

func _on_Inventory_Item_mouse_entered():
	emit_signal("tooltip", itemName)
