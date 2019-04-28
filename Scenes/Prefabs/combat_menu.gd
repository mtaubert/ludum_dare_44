extends MarginContainer

signal back(this)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_button(button):
	$HBoxContainer2/VBoxContainer.add_child(button)


func _on_back_pressed():
	emit_signal("back", self)
	
func show_details(action):
	$HBoxContainer2/HBoxContainer/details.text = action
