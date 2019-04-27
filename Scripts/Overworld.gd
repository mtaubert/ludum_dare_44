extends Node2D

onready var player = get_node("Mansion/Sorter/player_character")
var tileOffset
var playerPos

var doors = {}
var entities = {}
var torches = []
var fountainPos

var currentEntity = null

var currentState
 
enum PLAYERSTATE {
	IDLE,
	MOVING,
	WAITING_FOR_ENCOUNTER,
	TALKING_WITH_DEMON
}

var playerMoving = false
var playerWaitingForEncounter = false

func _ready():
	tileOffset = $Mansion.cell_size/2
	
	#Player setup
	player.position = $Mansion.map_to_world(Game_Manager.playerSpawn) + tileOffset
	playerPos = Game_Manager.playerSpawn
	player.connect("movement_done", self, "player_movement_done")
	Game_Manager.connect("chat_done", self, "demon_chat_done")
	
	Game_Manager.set_player(player)
	currentState = PLAYERSTATE.IDLE
	
	#entity and wall setup
	update_entities()
	place_walls()

#Setup --------------------------------------------------------------------------------------------------------------------
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
	for child in $Mansion/Sorter.get_children(): #Finds all entities already on the tilemap and centers them on the tile
		match child.type:
			"Fountain":
				fountainPos = $Mansion.world_to_map(child.position)
				entities[$Mansion.world_to_map(child.position)] = child
				child.position = $Mansion.map_to_world(fountainPos) + tileOffset
			"Torch":
				child.position = $Mansion.map_to_world($Mansion.world_to_map(child.position)) + tileOffset + Vector2(0,-1)
				torches.append($Mansion.world_to_map(child.position))
			"Demon":
				child.position = $Mansion.map_to_world($Mansion.world_to_map(child.position)) + tileOffset
				entities[$Mansion.world_to_map(child.position)] = child
				
	
	#Exit placement
	if $Mansion.get_used_cells_by_id(4).size() > 0: #Checks if any exit tiles exists, only needs the first one
		var exitLoc = $Mansion.get_used_cells_by_id(4)[0]
		$Mansion.set_cellv(exitLoc + Vector2(1,0), 4) #Sets the cell next to the exit to the exit as well
		var newExit = exit.instance()
		$Mansion/Sorter.add_child(newExit)
		newExit.position = $Mansion.map_to_world(exitLoc) + tileOffset
		#Both exit tiles get the reference to the exit
		entities[exitLoc] = newExit
		entities[exitLoc + Vector2(1,0)] = newExit

	Game_Manager.set_random_encounter_locations($Mansion.get_used_cells_by_id(1), entities.keys(), torches)
#Setup --------------------------------------------------------------------------------------------------------------------

#Input and movement -------------------------------------------------------------------------------------------------------
#Checks for player input
func _input(event):
	if currentState == PLAYERSTATE.IDLE:
		if Input.is_action_pressed("ui_right"):
			move_player(Vector2(1,0))
		elif Input.is_action_pressed("ui_left"):
			move_player(Vector2(-1,0))
		elif Input.is_action_pressed("ui_up"):
			move_player(Vector2(0,-1))
		elif Input.is_action_pressed("ui_down"):
			move_player(Vector2(0,1))
		elif Input.is_action_pressed("ui_select"):
			if currentEntity != null: #Only works if facing an entity
				currentEntity.interact()
				if currentEntity.type == "Demon": #Talking to demon state
					Game_Manager.update_player_spawn(playerPos) #Safety in case of fight
					currentState = PLAYERSTATE.TALKING_WITH_DEMON
		elif Input.is_action_just_released("ui_select"):
			if currentEntity != null:
				if currentEntity.type == "Fountain":
					currentEntity.stop_interact()
	
	if Input.is_action_pressed("menu"):
		$Mansion/Sorter/player_character.toggle_stats_view()

#moves player to the next tile
func move_player(direction:Vector2):
	var newPlayerPos = playerPos + direction
	player.set_facing(direction)
	
	check_for_entities(direction) #Checks if the player is moving towards an entity
	
	match $Mansion.get_cellv(newPlayerPos):
		1,3: #Floor and grass
			if currentEntity == null: #Stops player from walking onto entities
				playerPos = newPlayerPos
				player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
				currentState = PLAYERSTATE.MOVING
				if Game_Manager.encounter_chance(playerPos):
					currentState = PLAYERSTATE.WAITING_FOR_ENCOUNTER
		2: #Doors
			playerPos = newPlayerPos
			doors[playerPos].open_door(direction)
			player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
			currentState = PLAYERSTATE.MOVING
			yield(get_tree().create_timer(0.3), "timeout") #Moves again to get out of doorway
			move_player(direction)
		4: #Exit
			if entities[newPlayerPos].open:
				playerPos = newPlayerPos
				player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
				currentState = PLAYERSTATE.MOVING
				yield(get_tree().create_timer(0.3), "timeout") #Moves again to get out of doorway
				move_player(direction)
		5: #Stairs up
			Game_Manager.go_up()
		6: #Stairs down
			Game_Manager.go_down()
		_:
			pass

#Checks the tile the player is facing for an entity
func check_for_entities(direction:Vector2):
	var checkLoc = playerPos + direction #Location the player attempted to move
	if entities.has(checkLoc): #location is marked as containing an entity
		if currentEntity != entities[checkLoc] and currentEntity != null: #Looking at a new entity, not just the same old one
			currentEntity.unhighlight()
		currentEntity = entities[checkLoc] #Sets the entity at the location as current and highlights
		currentEntity.highlight()
	else: #No entity found
		if currentEntity != null: #Unhighlights current entity if present
			currentEntity.unhighlight()
			currentEntity = null

#Enables next movement input
func player_movement_done():
	if currentState != PLAYERSTATE.WAITING_FOR_ENCOUNTER:
		currentState = PLAYERSTATE.IDLE

#Returns to idle after talking to demon
func demon_chat_done():
	currentState = PLAYERSTATE.IDLE
#Input and movement -------------------------------------------------------------------------------------------------------