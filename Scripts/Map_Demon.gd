extends AnimatedSprite

var type = "Demon"

func _ready():
	$Highlight.hide()

func interact():
	pass

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()