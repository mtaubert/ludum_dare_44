extends Control

var show_the_man = false
onready var tween = get_node("the_man_stats/man_tween")
export var blood_val = 20
# Called when the node enters the scene tree for the first time.
func _ready():
	$the_man_stats.set_blood(blood_val)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sacrifice_pressed():
	show_the_man = not show_the_man
	if show_the_man:
		var target = $the_man_stats.position
		target.x = 80
		tween.interpolate_property($the_man_stats, "position", $the_man_stats.position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	else:
		var target = $the_man_stats.position
		target.x = -80
		tween.interpolate_property($the_man_stats, "position", $the_man_stats.position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

func _on_fight_pressed():
	blood_val += 20
	blood_val = blood_val %101
	$the_man_stats.set_blood(blood_val)
