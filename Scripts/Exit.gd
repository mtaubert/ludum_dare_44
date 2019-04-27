extends Sprite

var type = "Exit"
var doorTextures = [load("res://Assets/exit_closed.png"), load("res://Assets/exit_open.png")]
var open = false

export var winBloodLevel = 20

func _ready():
	texture = doorTextures[0]
	$Highlight.hide()

func interact():
	if not open:
		if Game_Manager.bloodSacrificeLevel >= 20:
			open = true
			texture = doorTextures[1]
	else:
		open = false
		texture = doorTextures[0]

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()