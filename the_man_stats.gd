extends Control
onready var blood = load("res://character_model/man_blood.png")
onready var mind = load("res://character_model/man_mind.png")
onready var heart = load("res://character_model/man_heart.png")
onready var finger = load("res://character_model/man_fingers.png")
onready var toe = load("res://character_model/man_toes.png")
onready var soul = load("res://character_model/man_soul.png")
onready var default = load("res://character_model/the_man_Stats.png")
onready var tween = get_node("Tween")
var cost = 0

signal paid_tribute(valid)
signal blood_paid(ammount)

func set_blood(val):
	#set the blood pool to a value between 0 and 100
	tween.interpolate_property($ProgressBar, "value", $ProgressBar.value, val, 0.1, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
func toggle_buttons(visible_in):
	$MarginContainer.visible = visible_in
	if not visible_in:
		$Sprite.texture = default
		$counter.text = ""
	
func _ready():
	Game_Manager.connect("update_blood", self, "update_blood")
	for item in get_tree().get_nodes_in_group("sacrifice_button"):
		item.connect("focus_entered", self, "update_man", [item])
		item.connect("mouse_entered", self, "update_man", [item])
		item.connect("pressed", self, "sacrifice", [item])
	print(Game_Manager.get_player_var("blood"))
	$ProgressBar.value = Game_Manager.get_player_var("blood")
	disable_buttons()
		
func update_man(item):
	print(item.name)
	$Sprite.texture = get(item.name)
	$counter.text = str(Game_Manager.get_player_var(item.name))
	
func update_blood():
	set_blood(Game_Manager.get_player_var("blood"))
	$counter.text = str(Game_Manager.get_player_var("blood"))

func _on_blood_pressed():
	emit_signal("blood_paid", 5)
	update_blood()
	
func disable_buttons():
	cost = 0
	for item in $MarginContainer/VBoxContainer.get_children():
		item.disabled = true
		
#func enable_buttons():
#	for item in $MarginContainer/VBoxContainer.get_children():
#		item.disabled = false
		
func sacrifice(item):
	disable_buttons()
	print("sacrifice " + str(cost)+ " " + str(item.name))
	if Game_Manager.get_player_var(item.name) > cost:
		Game_Manager.player_sacrifice(item.name, cost)
		update_man(item)
		emit_signal("paid_tribute", true)
	else:
		emit_signal("paid_tribute", false)
		
func enable_button(button, cost_in):
	cost = cost_in
	var node = get_node("MarginContainer/VBoxContainer/" + button)
	node.disabled = false
