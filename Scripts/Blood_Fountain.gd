extends Sprite

var type = "Fountain"
var stage = [load("res://scenery/blood_pit_empty.png"), load("res://scenery/blood_pit_low.png"), load("res://scenery/blood_pit_mid.png"), load("res://scenery/blood_pit_full.png")]

func _ready():
	texture = stage[0]
	$Highlight.hide()
	set_process(false)

func interact():
	set_process(true)
	$Blood.emitting = true

func stop_interact():
	set_process(false)
	$Blood.emitting = false

#slowly ticks up bloodLevel every 0.5 seconds
var secondsSinceInteract = 0
func _process(delta):
	secondsSinceInteract += delta
	
	if secondsSinceInteract > 0.5:
		Game_Manager.bloodSacrificeLevel += 1
		var bloodStage = int(Game_Manager.bloodSacrificeLevel/5)
		if bloodStage <= 3:
			texture = stage[bloodStage]
		else:
			texture = stage[3]
		
		secondsSinceInteract = 0

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	stop_interact()
	$Highlight.hide()
	$AnimationPlayer.stop()