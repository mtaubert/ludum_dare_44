extends Node2D

func start_game():
	Game_Manager.reset()
	get_tree().change_scene("res://Scenes/game_start.tscn")

func leave():
	get_tree().quit()
