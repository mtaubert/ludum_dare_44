extends Sprite

var type = "Torch"


func ready():
	randomize()
	yield(get_tree().create_timer(rand_range(0,0.3)), "timeout")
	$Flicker.play("flicker")