extends Node2D

onready var player = get_node("Mansion/Sorter/player_character")
export(Vector2) var playerSpawn
var tileOffset
var playerPos

var doors = {}
var entities = {}
var fountainPos

var currentEntity = null
var playerMoving = false

func _ready():
	tileOffset = $Mansion.cell_size/2
	player.position = $Mansion.map_to_world(playerSpawn) + tileOffset
	playerPos = playerSpawn
	player.connect("movement_done", self, "player_movement_done")
	
	update_entities()
	place_walls()

#Walls and doors
onready var wall = load("res://Scenes/Prefabs/Wall.tscn")
onready var door = load("res://Scenes/Prefabs/Door.tscn")
func place_walls():
	for pos in $Mansion.get_used_cells_by_id(0):
		var newWall = wall.instance()
		$Mansion/Sorter.add_child(newWall)
		newWall.position = $Mansion.map_to_world(pos) + tileOffset
	for pos in $Mansion.get_used_cells_by_id(2):
		var newDoor = door.instance()
		$Mansion/Sorter.add_child(newDoor)
		#Initialises door with the surrounding tile ids
		newDoor.setup([$Mansion.get_cellv(pos+Vector2(1,0)), $Mansion.get_cellv(pos+Vector2(-1,0)), $Mansion.get_cellv(pos+Vector2(0,1)), $Mansion.get_cellv(pos+Vector2(0,-1))])
		newDoor.position = $Mansion.map_to_world(pos) + tileOffset
		doors[pos] = newDoor #Adds the door to the entities list

func update_entities():
	for child in $Mansion/Sorter.get_children():
		match child.type:
			"Fountain":
				fountainPos = $Mansion.world_to_map(child.position)
				entities[$Mansion.world_to_map(child.position)] = child
				child.position = $Mansion.map_to_world(fountainPos) + tileOffset

#Checks for player input
func _input(event):
	if not playerMoving:
		if Input.is_action_pressed("ui_right"):
			move_player(Vector2(1,0))
		elif Input.is_action_pressed("ui_left"):
			move_player(Vector2(-1,0))
		elif Input.is_action_pressed("ui_up"):
			move_player(Vector2(0,-1))
		elif Input.is_action_pressed("ui_down"):
			move_player(Vector2(0,1))

#moves player to the next tile
func move_player(direction:Vector2):
	var newPlayerPos = playerPos + direction
	player.set_facing(direction)
	match $Mansion.get_cellv(newPlayerPos):
		1: #Floor and doors
			if not entities.has(newPlayerPos):
				playerPos = newPlayerPos
				player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
				playerMoving = true
		2:
			playerPos = newPlayerPos
			doors[playerPos].open_door(direction)
			player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
			playerMoving = true
			yield(get_tree().create_timer(0.3), "timeout")
			move_player(direction)
		_:
			pass
	
	check_for_entities(direction)

func check_for_entities(direction:Vector2):
	var checkLoc = playerPos + direction
	if entities.has(checkLoc):
		currentEntity = entities[checkLoc]
		currentEntity.highlight()
	else:
		if currentEntity != null:
			currentEntity.unhighlight()
			currentEntity = null

#Enables next movement input
func player_movement_done():
	playerMoving = false