extends Node2D

onready var player = get_node("Mansion/Sorter/player_character")
export(Vector2) var playerSpawn
var tileOffset
var playerPos

var playerMoving = false

func _ready():
	tileOffset = $Mansion.cell_size/2
	player.position = $Mansion.map_to_world(playerSpawn) + tileOffset
	playerPos = playerSpawn
	player.connect("movement_done", self, "player_movement_done")
	
	place_walls()

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
		newDoor.position = $Mansion.map_to_world(pos) + tileOffset

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
	match $Mansion.get_cellv(newPlayerPos):
		1,2: #Floor and doors
			playerPos = newPlayerPos
			player.move_player($Mansion.map_to_world(playerPos) + tileOffset, direction)
			playerMoving = true
		_:
			pass

#Enables next movement input
func player_movement_done():
	playerMoving = false