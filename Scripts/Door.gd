extends Sprite

var type = "Door"
var doorTextures = [load("res://Assets/door_vertical_closed.png"), load("res://Assets/door_vertical_open.png")]
var open = false
var orientation

func setup(surroundings):
	if surroundings[0] == 0 or surroundings[1] == 0:
		texture = doorTextures[1]
		offset = Vector2(0,-32)
		orientation = "horizontal"
	else:
		texture = doorTextures[0]
		offset = Vector2(0,-16)
		orientation = "vertical"

#Opens the door
func open_door(direction:Vector2):
	match(orientation):
		"horizontal":
			if direction.y > 0:
				texture = doorTextures[0]
				offset = Vector2(-29,32)
			else:
				texture = doorTextures[0]
				offset = Vector2(-29,-32)
		"vertical":
			if direction.x > 0:
				texture = doorTextures[1]
				offset = Vector2(32,-16)
			else:
				texture = doorTextures[1]
				offset = Vector2(-32,-16)
				flip_h = true
	yield(get_tree().create_timer(0.6), "timeout")
	close_door()

func close_door():
	match(orientation):
		"horizontal":
			texture = doorTextures[1]
			offset = Vector2(0,-32)
		"vertical":
			texture = doorTextures[0]
			offset = Vector2(0,-16)
			flip_h = false
