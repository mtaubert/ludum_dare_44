extends TextureRect

func setup(item):
	if item != null:
		$Item.texture = Item_Manager.items[item]["image"]
		visible = true
	else:
		visible = false