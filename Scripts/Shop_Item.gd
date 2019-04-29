extends TextureButton

var itemName

func _ready():
	Item_Manager.connect("item_purchased", self, "check_funds")

func setup(item, inInventory):
	
	$Availability.hide()
	$Lacking_Funds.hide()
	
	itemName = item
	$Item.texture = Item_Manager.items[item]["image"]
	$Item_Name.text = itemName
	$Item_Currency.texture = Item_Manager.currencies[Item_Manager.items[item]["cost"][1]]
	$Item_Price.text = "x" + String(Item_Manager.items[item]["cost"][0])
	
	check_funds()
	check_availability(inInventory)


func purchase():
	if Item_Manager.purchase_item(itemName):
		check_availability(true)

func check_availability(inInventory):
	if Item_Manager.items[itemName]["unique"] and inInventory:
		disabled = true
		$Lacking_Funds.hide()
		$Availability.show()

func check_funds():
	if not Item_Manager.can_purchase(itemName):
		disabled = true
		$Lacking_Funds.show()