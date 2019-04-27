extends Sprite

var type = "Door"
var doorTextures = [load("res://Assets/door_vertical_closed.png"), load("res://Assets/door_vertical_open.png")]
var open = false
var orientation

var openDoorOccluderPolygon = [Vector2(0,5), Vector2(64,5), Vector2(64,40), Vector2(0,40)]
var closedDoorOccluderPolygon = [Vector2(-32,13), Vector2(32,13), Vector2(32,48), Vector2(-32,48)]

func setup(surroundings):
	if surroundings[0] == 0 or surroundings[1] == 0:
		texture = doorTextures[1]
		offset = Vector2(0,-32)
		orientation = "horizontal"
	else:
		texture = doorTextures[0]
		offset = Vector2(0,-16)
		orientation = "vertical"
	update_occluder()

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
	update_occluder()
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
	update_occluder()

func update_occluder():
	var poly = []
	match(orientation):
		"horizontal":
			for point in openDoorOccluderPolygon:
				poly.append(point)
		"vertical":
			for point in closedDoorOccluderPolygon:
				poly.append(point)
	$Occluder.occluder.polygon = PoolVector2Array(poly)
	$Line2D.points = PoolVector2Array(poly)