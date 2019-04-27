extends Control
onready var blood = load("res://character_model/man_blood.png")
onready var mind = load("res://character_model/man_mind.png")
onready var heart = load("res://character_model/man_heart.png")
onready var finger = load("res://character_model/man_fingers.png")
onready var toe = load("res://character_model/man_toes.png")
onready var soul = load("res://character_model/man_soul.png")
onready var default = load("res://character_model/the_man_Stats.png")
onready var tween = get_node("Tween")

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
	for item in get_tree().get_nodes_in_group("sacrifice_button"):
		item.connect("focus_entered", self, "update_man", [item])
		item.connect("mouse_entered", self, "update_man", [item])
	print(Game_Manager.get_player_var("blood"))
	$ProgressBar.value = Game_Manager.get_player_var("blood")
		
func update_man(item):
	print(item.name)
	$Sprite.texture = get(item.name)
	$counter.text = str(Game_Manager.get_player_var(item.name))
	
func update_blood():
	$counter.text = str(Game_Manager.get_player_var("blood"))

func _on_blood_pressed():
	emit_signal("blood_paid", 5)
	update_blood()
