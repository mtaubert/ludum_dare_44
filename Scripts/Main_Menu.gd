extends Node2D

func start_game():
	Game_Manager.reset()
	get_tree().change_scene("res://Scenes/Bottom_Floor.tscn")

func leave():
	get_tree().quit()