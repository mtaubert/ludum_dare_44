extends Node

var houseLevels = ["Basement", "Bottom_Floor", "Top_Floor"]
var bloodSacrificeLevel = 0
var currentLevel = 1
var playerSpawn = Vector2(16,19)

func _ready():
	randomize()

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

var encounterLocations = []

#Initilises the encounter locations for the floor
func set_random_encounter_locations(floorCells, entityLocations, torchLocations):
	encounterLocations.clear()
	for entityLoc in entityLocations:
		var neighbors = [entityLoc+Vector2(-1,-1), entityLoc+Vector2(0,-1), entityLoc+Vector2(1,-1), entityLoc+Vector2(1,0), entityLoc+Vector2(1,1), entityLoc+Vector2(0,1), entityLoc+Vector2(-1,1), entityLoc+Vector2(-1,0)]
		for neighbor in neighbors:
			floorCells.erase(neighbor)
	for torchLoc in torchLocations:
		var neighbors = [torchLoc+Vector2(-1,-1), torchLoc+Vector2(0,-1), torchLoc+Vector2(1,-1), torchLoc+Vector2(1,0), torchLoc+Vector2(1,1), torchLoc+Vector2(0,1), torchLoc+Vector2(-1,1), torchLoc+Vector2(-1,0)]
		for neighbor in neighbors:
			floorCells.erase(neighbor)
	encounterLocations = floorCells

var encounterChance = 10
var player

func set_player(p):
	player = p
	player.connect("start_encounter", self, "start_encounter")

#Trigger encounter chance
func encounter_chance(location:Vector2):
	if encounterLocations.has(location):
		if randi()%100 < encounterChance: #Trigger encounter
			playerSpawn = location
			player.play_encounter_start()
			encounterChance = 10
		else:
			encounterChance +=2

func start_encounter():
	get_tree().change_scene("res://battle.tscn")
	
func end_encounter():
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")