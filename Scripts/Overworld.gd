extends Node2D

onready var player = get_node("Mansion/Sorter/player_character")
onready var playerTween = get_node("Mansion/Sorter/player_character/Player_Tween")
export(Vector2) var playerSpawn
var playerPos

var playerMoving = false

func _ready():
	player.position = $Mansion.map_to_world(playerSpawn)
	playerPos = playerSpawn
	player.connect("movement_done", self, "player_movement_done")

#Checks for player input
func _input(event):
	if not playerMoving:
		if Input.is_action_just_pressed("ui_right"):
			move_player(Vector2(1,0))
		elif Input.is_action_just_pressed("ui_left"):
			move_player(Vector2(-1,0))
		elif Input.is_action_just_pressed("ui_up"):
			move_player(Vector2(0,-1))
		elif Input.is_action_just_pressed("ui_down"):
			move_player(Vector2(0,1))

#moves player to the next tile
func move_player(direction:Vector2):
	var newPlayerPos = playerPos + direction
	playerPos = newPlayerPos
	player.move_player($Mansion.map_to_world(playerPos), direction)
	playerMoving = true

#Enables next movement input
func player_movement_done():
	playerMoving = false