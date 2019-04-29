extends Node

signal item_purchased()
signal consumable_used()

var playerInventory = []
var debugInv = ["Blood Bag","Blood Bag","Blood Bag","Demon Candle","Demon Candle","Demon Candle","Holy Water","Holy Water","Holy Water","Toe Knife","Finger Sickle","Blood Scepter","Demon Bell"]

var items = {
	"Finger Sickle": {
		"image": load("res://Assets/items/finger_sickle.png"),
		"cost": [4, "finger"],
		"unique": true,
		"effect":  "nick finger"
	},
	"Toe Knife": {
		"image": load("res://Assets/items/toe_knife.png"),
		"cost": [1, "toe"],
		"unique": true,
		"effect":  "nab toe"
	},
	"Blood Scepter": {
		"image": load("res://Assets/items/blood_scepter.png"),
		"cost": [99, "blood"],
		"unique": true,
		"effect":  "siphon blood"
	},
	"Demon Bell": {
		"image": load("res://Assets/items/demon_bell.png"),
		"cost": [1, "soul"],
		"unique": true,
		"effect":  "stun demon"
	},
	"Blood Bag": {
		"image": load("res://Assets/items/blood_bag.png"),
		"cost": [1, "finger"],
		"unique": false,
		"effect":  20,
		"encounter_use": null
	},
	"Holy Water": {
		"image": load("res://Assets/items/holy_water.png"),
		"cost": [1, "toe"],
		"unique": false,
		"effect": 33,
		"encounter_use": true
	},
	"Demon Candle": {
		"image": load("res://Assets/items/demon_candle.png"),
		"cost": [1, "toe"],
		"unique": false,
		"effect": null,
		"encounter_use": false
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

func _ready():
	playerInventory = debugInv
	pass

func give_item(item, ammount):
	if item in items.keys():
		if items[item]["unique"] and not item in playerInventory:
			playerInventory.append(item)
			playerInventory.sort()
		elif not items[item]["unique"]:
			for i in ammount:
				playerInventory.append(item)
				playerInventory.sort()
	else:
		match item:
			"blood":
				Game_Manager.blood += ammount
				if Game_Manager.blood > 100:
					Game_Manager.blood = 100
				Game_Manager.update_blood()
			"toe":
				Game_Manager.toe += ammount
			"finger":
				Game_Manager.finger += ammount
			"heart":
				Game_Manager.heart += ammount
			"mind":
				Game_Manager.mind += ammount
			"soul":
				Game_Manager.soul += ammount
	emit_signal("item_purchased")
	
#purchases an item
func purchase_item(item):
	if can_purchase(item):
		Game_Manager.player_sacrifice((items[item]["cost"][1]), items[item]["cost"][0])
		playerInventory.append(item)
		emit_signal("item_purchased")
		playerInventory.sort()
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

func remove_item_from_inventory(consumable):
	playerInventory.erase(consumable)
	emit_signal("consumable_used")
	playerInventory.sort()