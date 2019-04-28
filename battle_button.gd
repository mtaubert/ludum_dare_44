extends Button

signal battle_action(type)
signal show_details(type)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(action):
	text = action


func _on_battle_button_pressed():
	emit_signal("battle_action", text)


func _on_battle_button_focus_entered():
	emit_signal("show_details", text)


func _on_battle_button_mouse_entered():
	emit_signal("show_details", text)
