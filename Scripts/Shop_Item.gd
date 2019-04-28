extends TextureButton

var itemName

func setup(item):
	itemName = item
	$Item.texture = Item_Manager.items[item]["image"]
	$Item_Name.text = itemName
	$Item_Currency.texture = Item_Manager.currencies[Item_Manager.items[item]["cost"][1]]
	$Item_Price.text = "x" + String(Item_Manager.items[item]["cost"][0])

func purchase():
	if Item_Manager.purchase_item(itemName):
		self.queue_free()
