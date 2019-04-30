extends Node

signal item_purchased()
signal consumable_used()

var playerInventory = []
var debugInv = ["Blood Bag","Blood Bag","Blood Bag","Demon Candle","Demon Candle","Demon Candle","Holy Water","Holy Water","Holy Water","Toe Knife","Finger Sickle","Blood Scepter","Demon Bell"]

var items = {
	"Finger Sickle": {
		"image": load("res://Assets/items/finger_sickle.png"),
		"cost": [5, "finger"],
		"unique": true,
		"effect":  "nick finger"
	},
	"Toe Knife": {
		"image": load("res://Assets/items/toe_knife.png"),
		"cost": [5, "toe"],
		"unique": true,
		"effect":  "nab toe"
	},
	"Blood Scepter": {
		"image": load("res://Assets/items/blood_scepter.png"),
		"cost": [1, "mind"],
		"unique": true,
		"effect":  "siphon blood"
	},
	"Demon Bell": {
		"image": load("res://Assets/items/demon_bell.png"),
		"cost": [1, "heart"],
		"unique": true,
		"effect":  "stun demon"
	},
	"Blood Bag": {
		"image": load("res://Assets/items/blood_bag.png"),
		"cost": [2, "finger"],
		"unique": false,
		"effect":  25,
		"encounter_use": null
	},
	"Holy Water": {
		"image": load("res://Assets/items/holy_water.png"),
		"cost": [3, "toe"],
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
	#playerInventory = debugInv
	playerInventory.sort()
	emit_signal("item_purchased")
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
		playerInventory.sort()
		emit_signal("item_purchased")
		print(playerInventory)
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
	playerInventory.sort()
	emit_signal("consumable_used")
	print(playerInventory)	