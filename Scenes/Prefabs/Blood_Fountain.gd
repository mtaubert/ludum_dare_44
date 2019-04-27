extends Sprite

var type = "Fountain"
var bloodLevel = 0
var stage = [load("res://scenery/blood_pit_empty.png"), load("res://scenery/blood_pit_low.png"), load("res://scenery/blood_pit_mid.png"), load("res://scenery/blood_pit_full.png")]

func _ready():
	texture = stage[0]
	$Highlight.hide()

func pay_in_blood():
	bloodLevel += 1
	texture = stage[int(bloodLevel/5)]

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()