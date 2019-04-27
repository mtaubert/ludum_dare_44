extends Node2D

onready var player = get_node("Mansion/Sorter/player_character")
onready var playerTween = get_node("Mansion/Sorter/player_character/Player_Tween")
export(Vector2) var playerSpawn
var playerPos

func _ready():
	player.position = $Mansion.map_to_world(playerSpawn)
	playerPos = playerSpawn

func _input(event):
	if Input.is_action_just_pressed("ui_right"):
		move_player(Vector2(1,0))
	elif Input.is_action_just_pressed("ui_left"):
		move_player(Vector2(-1,0))
	elif Input.is_action_just_pressed("ui_up"):
		move_player(Vector2(0,-1))
	elif Input.is_action_just_pressed("ui_down"):
		move_player(Vector2(0,1))

func _process(delta):
	pass

func move_player(direction:Vector2):
	var newPlayerPos = playerPos + direction
	playerPos = newPlayerPos
	player.move_player($Mansion.map_to_world(playerPos))
