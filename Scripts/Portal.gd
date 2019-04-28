extends Sprite

var type = "Portal"

func _ready():
	unhighlight()

func interact():
	pass
	#Go to hell

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()