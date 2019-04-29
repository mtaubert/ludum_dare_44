extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game_Manager.won:
		$ColorRect/MarginContainer/VBoxContainer/Label.text = "Eventually Johnny made it out.\nAfter all the bargains.\nHe was finally free!"
	else:
		$ColorRect/MarginContainer/VBoxContainer/Label.text = "Alas, Johnny fell.\nAll his life spent away.\nIs this how the story went?"


func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Main_Menu.tscn")
