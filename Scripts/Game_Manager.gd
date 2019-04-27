extends Node

var houseLevels = ["Bottom_Floor", "Top_Floor", "Basement"]
var bloodSacrificeLevel = 0
var currentLevel = 0
var playerSpawn = Vector2(16,19)

func go_up():
	match currentLevel:
		0:
			get_tree().change_scene("res://Scenes/" + houseLevels[1] + ".tscn")
			playerSpawn = Vector2(10,1)
		-1:
			get_tree().change_scene("res://Scenes/" + houseLevels[0] + ".tscn")
			playerSpawn = Vector2(19,10)
	currentLevel += 1

func go_down():
	match currentLevel:
		1:
			get_tree().change_scene("res://Scenes/" + houseLevels[0] + ".tscn")
			playerSpawn = Vector2(12,10)
		0:
			get_tree().change_scene("res://Scenes/" + houseLevels[2] + ".tscn")
			playerSpawn = Vector2(10,1)
	currentLevel -=1

var encounterLocations = []

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

func encounter_chance(location:Vector2):
	if encounterLocations.has(location):
		print("Encounter location" + String(location))

func start_encounter(location: Vector2):
	get_tree().change_scene("res://Scenes/battle.tscn")
	playerSpawn = location
	
func end_encounter():
	get_tree().change_scene("res://Scenes/" + houseLevels[currentLevel] + ".tscn")