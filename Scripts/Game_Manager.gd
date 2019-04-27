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