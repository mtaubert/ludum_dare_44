extends Sprite

var type = "Portal"

func _ready():
	unhighlight()

func interact():
	if Game_Manager.currentLevel >= 0:
		Game_Manager.go_to_hell()
	else:
		Game_Manager.go_up()

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()