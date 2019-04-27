extends Sprite

var type = "Exit"
var doorTextures = [load("res://Assets/exit_closed.png"), load("res://Assets/exit_open.png")]
var open = false

func _ready():
	texture = doorTextures[0]
	$Highlight.hide()

func interact():
	texture = doorTextures[1]

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()