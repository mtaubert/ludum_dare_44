extends MarginContainer

signal back(this)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_button(button):
	$HBoxContainer2/VBoxContainer.add_child(button)
	if	len($HBoxContainer2/VBoxContainer.get_children()) > 1:
		var last = $HBoxContainer2/VBoxContainer.get_child($HBoxContainer2/VBoxContainer.get_child_count()-1)
		for item in $HBoxContainer2/VBoxContainer.get_children():
			print(item)
			print(last)
			item.set_focus_previous(last.get_path())
			last.set_focus_next(item.get_path())
			last = item


func _on_back_pressed():
	emit_signal("back", self)
	
func show_details(action):
	if Game_Manager.action_definitions.has(action) or Game_Manager.item_actions.has(action):
		$HBoxContainer2/HBoxContainer/details.text = Game_Manager.action_definitions[action]["text"]
	else:
		$HBoxContainer2/HBoxContainer/details.text = action

func focus_menu():
	$HBoxContainer2/VBoxContainer.get_child(0).grab_focus()