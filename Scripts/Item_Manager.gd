extends Node

signal item_purchased()

var playerInventory = []

var items = {
	"Finger Sickle": {
		"image": load("res://Assets/items/finger_sickle.png"),
		"cost": [4, "finger"],
		"unique": true
	},
	"Toe Knife": {
		"image": load("res://Assets/items/toe_knife.png"),
		"cost": [1, "toe"],
		"unique": true
	},
	"Blood Scepter": {
		"image": load("res://Assets/items/blood_scepter.png"),
		"cost": [99, "blood"],
		"unique": true
	},
	"Demon Bell": {
		"image": load("res://Assets/items/demon_bell.png"),
		"cost": [1, "soul"],
		"unique": true
	},
	"Blood Bag": {
		"image": load("res://Assets/items/blood_bag.png"),
		"cost": [1, "finger"],
		"unique": false
	},
	"Holy Water": {
		"image": load("res://Assets/items/holy_water.png"),
		"cost": [1, "toe"],
		"unique": false
	}
}

var currencies = {
	"blood": load("res://Assets/items/blood.png"),
	"toe": load("res://Assets/items/toe.png"),
	"finger": load("res://Assets/items/finger.png"),
	"mind": load("res://Assets/items/mind.png"),
	"soul": load("res://Assets/items/soul.png"),
	"heart": load("res://Assets/items/heart.png")
}

#purchases an item
func purchase_item(item):
	if can_purchase(item):
		Game_Manager.player_sacrifice((items[item]["cost"][1]), items[item]["cost"][0])
		playerInventory.append(item)
		emit_signal("item_purchased")
		return true
	else:
		return false

#Checks if an item is available
func can_purchase(item):
	if Game_Manager.get_player_var(items[item]["cost"][1]) > items[item]["cost"][0]:
		return true
	return false

func get_unique_items():
	var uniques = []
	
	for item in playerInventory:
		if items[item]["unique"]:
			uniques.append(item)
	
	return uniques

func get_consumables():
	var consumbles = {}
	
	for item in playerInventory:
		if !items[item]["unique"]:
			if consumbles.has(item):
				consumbles[item] += 1
			else:
				consumbles[item] = 1
	
	return consumbles