extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/fight.grab_focus()

func focus_menu():
	$VBoxContainer/HBoxContainer/fight.grab_focus()