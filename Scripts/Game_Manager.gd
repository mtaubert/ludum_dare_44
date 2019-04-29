extends Node

var houseLevels = ["Basement", "Bottom_Floor", "Top_Floor"]
var bloodSacrificeLevel = 0
var currentLevel = 1
var playerSpawn = Vector2(16,19)
var blood_fountain_cost = 10

signal update_blood()
export var blood = 100
export var heart = 1
export var soul = 1
export var mind = 1
export var finger = 10
export var toe = 10

var item_actions = ["nab toe", "nick finger", "siphon blood", "stun demon"]
var attack_actions = ["struggle", "dodge"]
var talk_actions = ["reason", "plead", "threaten", "compliment"]
var battleJSON = "res://Assets/battle_actions.json"
var action_definitions = {}
func _ready():
	randomize()
	load_battle_actions()


#load battle action details
func load_battle_actions():
	var file = File.new()
	file.open(battleJSON, file.READ)
	var fileJSON = JSON.parse(file.get_as_text())
	
	var tempDialogStore = {}
	
	if fileJSON.error == OK:
		tempDialogStore = fileJSON.result
	
	action_definitions = tempDialogStore
	print(action_definitions)
	
	
func get_player_var(name_in):
	return get(name_in)

func player_sacrifice(name_in, ammount):
	var tmp = get(name_in) 
	tmp -= ammount
	set(name_in, tmp)
	print("you lost a " + name_in)
	print(get(name_in))

func player_gain(name_in, ammount):
	var tmp = get(name_in)
	tmp += ammount
	set(name_in, tmp)
	
	match(name_in):
		"blood":
			if blood > 100:
				blood = 100
			emit_signal("update_blood")
		"finger":
			if finger > 10:
				finger = 10
		"toe":
			if toe > 10:
				toe = 10

#Mansion floor movement ---------------------------------------------------------------------------------------------------
func go_up():
	currentLevel += 1
	match currentLevel:
		2:
			playerSpawn = Vector2(10,1)
		1:
			playerSpawn = Vector2(19,10)
		0:
			playerSpawn = Vector2(14,11)
	player.fade_out()
	yield(get_tree().create_timer(1), "timeout")
	
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")

func go_down():
	currentLevel -= 1
	match currentLevel:
		1:
			playerSpawn = Vector2(12,10)
		0:
			playerSpawn = Vector2(10,1)
			
	player.fade_out()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")
	

func go_to_hell():
	currentLevel -= 1
	playerSpawn = Vector2(13,10)
	player.fade_out()
	yield(get_tree().create_timer(1), "timeout")
	
	get_tree().change_scene("res://Scenes/Hell.tscn")
	
#Mansion floor movement ---------------------------------------------------------------------------------------------------

#Encounters ---------------------------------------------------------------------------------------------------------------
signal encounter_state()
var encounterLocations = []

#Initilises the encounter locations for the floor
func set_random_encounter_locations(floorCells, entityLocations, torchLocations):
	encounterLocations.clear()
	for entityLoc in entityLocations:
		var neighbors = [entityLoc, entityLoc+Vector2(-1,-1), entityLoc+Vector2(0,-1), entityLoc+Vector2(1,-1), entityLoc+Vector2(1,0), entityLoc+Vector2(1,1), entityLoc+Vector2(0,1), entityLoc+Vector2(-1,1), entityLoc+Vector2(-1,0)]
		for neighbor in neighbors:
			floorCells.erase(neighbor)
	for torchLoc in torchLocations:
		var neighbors = [torchLoc, torchLoc+Vector2(-1,-1), torchLoc+Vector2(0,-1), torchLoc+Vector2(1,-1), torchLoc+Vector2(1,0), torchLoc+Vector2(1,1), torchLoc+Vector2(0,1), torchLoc+Vector2(-1,1), torchLoc+Vector2(-1,0)]
		for neighbor in neighbors:
			floorCells.erase(neighbor)
	encounterLocations = floorCells

var encounterChance = 2
var player
var specificEnemy = null
var inEncounter = false

func set_player(p):
	player = p
	player.connect("start_encounter", self, "start_encounter")

func update_player_spawn(playerLoc):
	playerSpawn = playerLoc

#Trigger encounter chance
func encounter_chance(location:Vector2):
	if encounterLocations.has(location):
		if randi()%100 < encounterChance: #Trigger encounter
			playerSpawn = location
			player.play_encounter_start()
			return true
		else:
			return false

#Starts a random encounter
func start_encounter():
	specificEnemy = null
	player.fade_out()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://battle.tscn")
	inEncounter = true
	emit_signal("encounter_state", inEncounter)

#Starts a specific encounter
func start_encounter_against(demonID):
	specificEnemy = demonID
	player.fade_out()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://battle.tscn")
	inEncounter = true
	emit_signal("encounter_state", inEncounter)

func end_encounter():
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")
	
	yield(get_tree().create_timer(1), "timeout")
	player.fade_in()
	inEncounter = false
	emit_signal("encounter_state", inEncounter)
#Encounters ---------------------------------------------------------------------------------------------------------------

#Sacrifices ---------------------------------------------------------------------------------------------------------------
func blood_sacrifice():
	player.open_menu()
	if player._on_the_man_stats_blood_paid(blood_fountain_cost):
		bloodSacrificeLevel += 1
		emit_signal("update_blood")
		return true
	else:
		return false
		
func can_pay_blood():
	return blood > blood_fountain_cost
#Sacrifices ---------------------------------------------------------------------------------------------------------------

#Consumables --------------------------------------------------------------------------------------------------------------
func use_consumable(consumable):
	match(consumable):
		"Blood Bag":
			var bloodAmount = Item_Manager.items[consumable]["effect"]
			if blood < 95:
				blood += bloodAmount
				if blood > 100: #Can't go above 100 blood
					blood = 100
				emit_signal("update_blood")
				Item_Manager.remove_item_from_inventory(consumable)
		"Holy Water":
			if inEncounter:
				Item_Manager.remove_item_from_inventory(consumable)
		"Demon Candle":
			if !inEncounter:
				player.play_encounter_start()
				Item_Manager.remove_item_from_inventory(consumable)
#Consumables --------------------------------------------------------------------------------------------------------------

#Demon chat ---------------------------------------------------------------------------------------------------------------
#Demon dialog signal
signal demon_dialog_start()
signal chat_done()

func start_dialog(demonID):
	emit_signal("demon_dialog_start", demonID)

func dialog_over():
	emit_signal("chat_done")
#Demon chat ---------------------------------------------------------------------------------------------------------------