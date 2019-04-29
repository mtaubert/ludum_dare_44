extends Node

var playerInventory = []

var items = {
	"Finger Sickle": {
		"image": load("res://Assets/items/finger_sickle.png"),
		"cost": [4, "finger"],
	},
	"Toe Knife": {
		"image": load("res://Assets/items/toe_knife.png"),
		"cost": [1, "toe"]
	},
	"Blood Scepter": {
		"image": load("res://Assets/items/blood_scepter.png"),
		"cost": [99, "blood"]
	},
	"Demon Bell": {
		"image": load("res://Assets/items/demon_bell.png"),
		"cost": [1, "soul"]
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
	if Game_Manager.get_player_var(items[item]["cost"][1]) > items[item]["cost"][0]:
		Game_Manager.player_sacrifice((items[item]["cost"][1]), items[item]["cost"][0])
		playerInventory.append(item)
		return true
	else:
		return false
		