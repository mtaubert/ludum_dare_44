extends Sprite

var type = "Exit"
var doorTextures = [load("res://Assets/exit_closed.png"), load("res://Assets/exit_open.png")]
var open = false

export var winBloodLevel = 20

func _ready():
	texture = doorTextures[0]
	$Highlight.hide()

#Win condition here
func interact():
	if not open:
		if Game_Manager.bloodSacrificeLevel >= 20:
			var items = Item_Manager.get_unique_items()
			if items.has("Toe Knife") and items.has("Finger Sickle") and items.has("Blood Scepter") and items.has("Demon Bell"):
				if Game_Manager.heart > 0 and Game_Manager.soul > 0 and Game_Manager.mind > 0:
					open = true
					texture = doorTextures[1]

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()