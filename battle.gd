extends Control

var show_the_man = false
onready var tween = get_node("CanvasLayer/the_man_stats/man_tween")
export var blood_count = 100

onready var enemy_0 = load("res://demon_model/commandeer_sheet.tres")
onready var enemy_1 = load("res://demon_model/keeper_demon_sheet.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/the_man_stats.set_blood(blood_count)
	randomize()
	$Node2D/enemy.frames = get("enemy_" + str(randi() % 2))
	print("enemy_" + str(randi() % 2))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sacrifice_pressed():
	show_the_man = not show_the_man
	if show_the_man:
		$CanvasLayer/the_man_stats.toggle_buttons(true)
		var target = $CanvasLayer/the_man_stats.rect_position
		target.x = 80
		tween.interpolate_property($CanvasLayer/the_man_stats, "rect_position", $CanvasLayer/the_man_stats.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	else:
		
		$CanvasLayer/the_man_stats.toggle_buttons(false)
		var target = $CanvasLayer/the_man_stats.rect_position
		target.x = -200
		tween.interpolate_property($CanvasLayer/the_man_stats, "rect_position", $CanvasLayer/the_man_stats.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

func _on_fight_pressed():
	pass
	#blood_count += 20
	#blood_val = blood_val %101
	#$CanvasLayer/the_man_stats.set_blood(blood_val)


func _on_flee_pressed():
	Game_Manager.end_encounter()


func _on_the_man_stats_blood_paid(ammount):
	if blood_count > ammount:
		blood_count -= ammount
	$CanvasLayer/the_man_stats.set_blood(blood_count)
