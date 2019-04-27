extends Node2D

onready var tween = get_node("Tween")

func set_blood(val):
	#set the blood pool to a value between 0 and 100
	tween.interpolate_property($ProgressBar, "value", $ProgressBar.value, val, 0.1, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
