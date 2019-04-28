extends AnimatedSprite

export var demonID = 1
var type = "Demon"


func _ready():
	$Highlight.hide()
	frames = Demon_Manager.demons[String(demonID)]["map_animations"]

func interact():
	Game_Manager.start_dialog(demonID)

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()