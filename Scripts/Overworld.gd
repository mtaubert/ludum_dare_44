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
onready var item = load("res://Scenes/Prefabs/Overworld_Item.tscn")

func place_walls():
	for pos in $Mansion.get_used_cells_by_id(0): #Walls
		var newWall = wall.instance()
		$Mansion/Sorter.add_child(newWall)
		newWall.position = $Mansion.map_to_world(pos) + tileOffset
		if Game_Manager.currentLevel < 0:
			newWall.modulate = Color("#8B0000")
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
				child.position = $Mansion.map_to_world(fountainPos) + tileOffset + Vector2(0,-1)
			"Torch":
				child.position = $Mansion.map_to_world($Mansion.world_to_map(child.position)) + tileOffset + Vector2(0,-1)
				torches.append($Mansion.world_to_map(child.position))
			"Demon":
				child.position = $Mansion.map_to_world($Mansion.world_to_map(child.position)) + tileOffset + Vector2(0,-1)
				entities[$Mansion.world_to_map(child.position)] = child
			"Portal":
				child.position = $Mansion.map_to_world($Mansion.world_to_map(child.position)) + tileOffset + Vector2(0,-1)
				entities[$Mansion.world_to_map(child.position)] = child
	
	print(Game_Manager.floor_items[Game_Manager.currentLevel])
	
	for itemPos in Game_Manager.floor_items[Game_Manager.currentLevel]:
		print(Game_Manager.pickedUpItems)
		if !Game_Manager.pickedUpItems[Game_Manager.currentLevel+1].has(itemPos):
			var newItem = item.instance()
			$Mansion/Sorter.add_child(newItem)
			newItem.position = $Mansion.map_to_world(itemPos) + tileOffset
			newItem.setup(Game_Manager.floor_items[Game_Manager.currentLevel][itemPos][0],Game_Manager.floor_items[Game_Manager.currentLevel][itemPos][1])
			entities[itemPos] = newItem
			newItem.connect("picked_up", self, "picked_up_item")
	
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

	Game_Manager.set_random_encounter_locations($Mansion.get_used_cells_by_id(1) + $Mansion.get_used_cells_by_id(7), entities.keys(), torches)

func picked_up_item(pos):
	print("picked up " + str(pos))
	var item = entities[$Mansion.world_to_map(pos)]
	entities.erase($Mansion.world_to_map(pos))
	currentEntity = null
	item.queue_free()
	Game_Manager.pickedUpItems[Game_Manager.currentLevel+1].append($Mansion.world_to_map(pos))

#Setup --------------------------------------------------------------------------------------------------------------------

#Input and movement -------------------------------------------------------------------------------------------------------
#Checks for player input
func _process(delta):
	if currentState == PLAYERSTATE.IDLE:
		if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
			move_player(Vector2(0, Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")))
		elif Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
			move_player(Vector2(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"), 0))
		else:
			player.set_facing(player.dir)
			#this function returns to idle
		if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
			player.set_facing(player.dir)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
			player.set_facing(player.dir)
	
	if Input.is_action_just_pressed("ui_select"):
		if currentEntity != null and currentState == PLAYERSTATE.IDLE: #Only works if facing an entity
			if currentEntity.type == "Item":
				currentEntity.interact()
			else:
				currentEntity.interact()
				if currentEntity.type == "Demon": #Talking to demon state
					Game_Manager.update_player_spawn(playerPos) #Safety in case of fight
					currentState = PLAYERSTATE.TALKING_WITH_DEMON
					if $Mansion/Sorter/player_character.stats_pos != -140:
						$Mansion/Sorter/player_character.toggle_stats_view()
					$Mansion/Sorter/player_character.hide_tip()
	elif Input.is_action_just_released("ui_select"):
		if currentEntity != null and currentState == PLAYERSTATE.IDLE:
			if currentEntity.type == "Fountain":
				currentEntity.stop_interact()
	
	if Input.is_action_pressed("menu"):
		if not currentState == PLAYERSTATE.TALKING_WITH_DEMON:
			player.toggle_stats_view()
	
	if Input.is_action_just_pressed("ui_page_up"):
		get_tree().change_scene("res://Scenes/Main_Menu.tscn")

#moves player to the next tile
func move_player(direction:Vector2):
	var newPlayerPos = playerPos + direction
	player.soft_set_facing(direction)
	
	match $Mansion.get_cellv(newPlayerPos):
		1,3,7: #Floor and grass and hell tile
			if !entities.has(newPlayerPos): #Stops player from walking onto entities
				playerPos = newPlayerPos
				player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
				currentState = PLAYERSTATE.MOVING
				if Game_Manager.encounter_chance(playerPos):
					currentState = PLAYERSTATE.WAITING_FOR_ENCOUNTER
		2: #Doors
			playerPos = newPlayerPos
			doors[playerPos].open_door(direction)
			playerPos += direction
			player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction*2)
			currentState = PLAYERSTATE.MOVING
		4: #Exit
			if entities[newPlayerPos].open:
				playerPos = newPlayerPos + direction*9
				player.game_won($Mansion.map_to_world(playerPos) + tileOffset, direction)
				#player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction*2)
				currentState = PLAYERSTATE.MOVING
			else:
				$Mansion/Sorter/player_character.check_win()
		5: #Stairs up
			currentState = PLAYERSTATE.MOVING
			Game_Manager.go_up()
		6: #Stairs down
			currentState = PLAYERSTATE.MOVING
			Game_Manager.go_down()
		_:
			pass
		
	check_for_entities(direction) #Checks if the player is moving towards an entity

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