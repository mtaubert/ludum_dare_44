extends Node2D

onready var player = get_node("Mansion/Sorter/player_character")
var tileOffset
var playerPos

var doors = {}
var entities = {}
var torches = []
var fountainPos

var currentEntity = null
var playerMoving = false
var playerWaitingForEncounter = false

func _ready():
	tileOffset = $Mansion.cell_size/2
	player.position = $Mansion.map_to_world(Game_Manager.playerSpawn) + tileOffset
	playerPos = Game_Manager.playerSpawn
	player.connect("movement_done", self, "player_movement_done")
	
	Game_Manager.set_player(player)
	
	update_entities()
	place_walls()

#Walls and doors
onready var wall = load("res://Scenes/Prefabs/Wall.tscn")
onready var door = load("res://Scenes/Prefabs/Door.tscn")
onready var exit = load("res://Scenes/Prefabs/Exit.tscn")

func place_walls():
	for pos in $Mansion.get_used_cells_by_id(0): #Walls
		var newWall = wall.instance()
		$Mansion/Sorter.add_child(newWall)
		newWall.position = $Mansion.map_to_world(pos) + tileOffset
	for pos in $Mansion.get_used_cells_by_id(2): #Doors
		var newDoor = door.instance()
		$Mansion/Sorter.add_child(newDoor)
		#Initialises door with the surrounding tile ids
		newDoor.setup([$Mansion.get_cellv(pos+Vector2(1,0)), $Mansion.get_cellv(pos+Vector2(-1,0)), $Mansion.get_cellv(pos+Vector2(0,1)), $Mansion.get_cellv(pos+Vector2(0,-1))])
		newDoor.position = $Mansion.map_to_world(pos) + tileOffset
		doors[pos] = newDoor #Adds the door to the entities list

#Updates entities and places exit
func update_entities():
	for child in $Mansion/Sorter.get_children():
		match child.type:
			"Fountain":
				fountainPos = $Mansion.world_to_map(child.position)
				entities[$Mansion.world_to_map(child.position)] = child
				child.position = $Mansion.map_to_world(fountainPos) + tileOffset
			"Torch":
				child.position = $Mansion.map_to_world($Mansion.world_to_map(child.position)) + tileOffset + Vector2(0,-1)
				torches.append($Mansion.world_to_map(child.position))
	
	#Exit placement
	if $Mansion.get_used_cells_by_id(4).size() > 0:
		var exitLoc = $Mansion.get_used_cells_by_id(4)[0]
		$Mansion.set_cellv(exitLoc + Vector2(1,0), 4) #Sets the cell next to the exit to the exit as well
		var newExit = exit.instance()
		$Mansion/Sorter.add_child(newExit)
		newExit.position = $Mansion.map_to_world(exitLoc) + tileOffset
		#Both exit tiles get the reference to the exit
		entities[exitLoc] = newExit
		entities[exitLoc + Vector2(1,0)] = newExit
	
	print(entities.keys())
	Game_Manager.set_random_encounter_locations($Mansion.get_used_cells_by_id(1), entities.keys(), torches)

#Checks for player input
func _input(event):
	if not playerMoving and not playerWaitingForEncounter:
		if Input.is_action_pressed("ui_right"):
			move_player(Vector2(1,0))
		elif Input.is_action_pressed("ui_left"):
			move_player(Vector2(-1,0))
		elif Input.is_action_pressed("ui_up"):
			move_player(Vector2(0,-1))
		elif Input.is_action_pressed("ui_down"):
			move_player(Vector2(0,1))
		elif Input.is_action_pressed("ui_select"):
			if currentEntity != null:
				currentEntity.interact()
		elif Input.is_action_just_released("ui_select"):
			if currentEntity != null:
				if currentEntity.type == "Fountain":
					currentEntity.stop_interact()
		elif Input.is_action_pressed("menu"):
			$Mansion/Sorter/player_character.toggle_stats_view()

#moves player to the next tile
func move_player(direction:Vector2):
	var newPlayerPos = playerPos + direction
	player.set_facing(direction)
	match $Mansion.get_cellv(newPlayerPos):
		1,3: #Floor and grass
			if not entities.has(newPlayerPos): #Stops player from walking onto entities
				playerPos = newPlayerPos
				player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
				playerMoving = true
				playerWaitingForEncounter = Game_Manager.encounter_chance(playerPos)
		2: #Doors
			playerPos = newPlayerPos
			doors[playerPos].open_door(direction)
			player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
			playerMoving = true
			yield(get_tree().create_timer(0.3), "timeout")
			move_player(direction)
		4: #Exit
			if entities[newPlayerPos].open:
				playerPos = newPlayerPos
				player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
				playerMoving = true
				yield(get_tree().create_timer(0.3), "timeout")
				move_player(direction)
		5: #Stairs up
			Game_Manager.go_up()
		6: #Stairs down
			Game_Manager.go_down()
		_:
			pass
	
	check_for_entities(direction)

#Checks the tile the player is facing for an entity
func check_for_entities(direction:Vector2):
	var checkLoc = playerPos + direction
	if entities.has(checkLoc):
		if currentEntity != entities[checkLoc] and currentEntity != null:
			currentEntity.unhighlight()
		currentEntity = entities[checkLoc]
		currentEntity.highlight()
	else:
		if currentEntity != null:
			currentEntity.unhighlight()
			currentEntity = null

#Enables next movement input
func player_movement_done():
	playerMoving = false