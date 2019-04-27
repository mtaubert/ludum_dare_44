extends AnimatedSprite

export var demonID = 1
export var demonName = "wiggles"
var type = "Demon"

var dialog = {
	"opener": {
		"text": "Puny mortal, why did you come here?",
		"accept": "follow_up",
		"decline": null,
		"accept_text": "What?",
		"decline_text": null,
	},
	"follow_up": {
		"text": "Whay are you here? Did you want to fight me?",
		"accept": 1,
		"decline": "final",
		"accept_text": "Sure, thing",
		"decline_text": "I'm good",
	},
	"final": {
		"text": "Fine, then leave me.",
		"accept": null,
		"decline": null,
		"accept_text": null,
		"decline_text": null,
	}
}

func _ready():
	$Highlight.hide()

func interact():
	Game_Manager.start_dialog(demonName, demonID, dialog)

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()