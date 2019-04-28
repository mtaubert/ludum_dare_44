extends Node

var houseLevels = ["Basement", "Bottom_Floor", "Top_Floor"]
var bloodSacrificeLevel = 0
var currentLevel = 1
var playerSpawn = Vector2(16,19)
var blood_fountain_cost = 10

export var blood = 100
export var heart = 1
export var soul = 1
export var mind = 1
export var finger = 10
export var toe = 10

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
	
	
func get_player_var(name):
	return get(name)

#Mansion floor movement ---------------------------------------------------------------------------------------------------
func go_up():
	currentLevel += 1
	match currentLevel:
		2:
			playerSpawn = Vector2(10,1)
		1:
			playerSpawn = Vector2(19,10)
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")

func go_down():
	currentLevel -= 1
	match currentLevel:
		1:
			playerSpawn = Vector2(12,10)
		0:
			playerSpawn = Vector2(10,1)
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")
#Mansion floor movement ---------------------------------------------------------------------------------------------------

#Encounters ---------------------------------------------------------------------------------------------------------------
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

var encounterChance = 0
var player
var specificEnemy = null

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
			encounterChance = 10
			return true
		else:
			return false
			encounterChance +=0

#Starts a random encounter
func start_encounter():
	specificEnemy = null
	get_tree().change_scene("res://battle.tscn")

#Starts a specific encounter
func start_encounter_against(demonID):
	specificEnemy = demonID
	get_tree().change_scene("res://battle.tscn")

func end_encounter():
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")
#Encounters ---------------------------------------------------------------------------------------------------------------

#Sacrifices ---------------------------------------------------------------------------------------------------------------
func blood_sacrifice():
	player.open_menu()
	if player._on_the_man_stats_blood_paid(blood_fountain_cost):
		bloodSacrificeLevel += 1
		player.update_blood()
		return true
	else:
		return false
		
func can_pay_blood():
	return blood > blood_fountain_cost
#Sacrifices ---------------------------------------------------------------------------------------------------------------


#Demon chat ---------------------------------------------------------------------------------------------------------------
#Demon dialog signal
signal demon_dialog_start()
signal chat_done()

func start_dialog(demonID):
	emit_signal("demon_dialog_start", demonID)

func dialog_over():
	emit_signal("chat_done")
#Demon chat ---------------------------------------------------------------------------------------------------------------