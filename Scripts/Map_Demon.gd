extends AnimatedSprite

export var demonID = 1
var type = "Demon"

var dialog = {
	"opener": {
		"text": "Puny mortal, why did you come here?",
		"accept": "follow_up",
		"decline": null
	},
	"follow_up": {
		"text": "Do you want to hear that again?",
		"accept": "opener",
		"decline": "final"
	},
	"final": {
		"text": "Good, now vanish.",
		"accept": null,
		"decline": null
	}
}

func _ready():
	$Highlight.hide()

func interact():
	Game_Manager.start_dialog(demonID, dialog)

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()