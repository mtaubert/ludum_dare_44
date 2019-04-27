extends Node

var houseLevels = ["Bottom_Floor", "Top_Floor"]
var bloodSacrificeLevel = 0
var currentLevel = 0

func go_up():
	match currentLevel:
		0:
			get_tree().change_scene("res://Scenes/" + houseLevels[1] + ".tscn")
	currentLevel += 1

func go_down():
	match currentLevel:
		1:
			get_tree().change_scene("res://Scenes/" + houseLevels[0] + ".tscn")
	currentLevel -=1