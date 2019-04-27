extends Node2D

signal movement_done()

var type = "Player"
var dir = Vector2()
export var speed = 1000
export var limits = [0, 0, 1280, 1024]
onready var sprite = get_node("KinematicBody2D/Sprite")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.limit_left = limits[0]
	$Camera2D.limit_top = limits[1]
	$Camera2D.limit_right = limits[2]
	$Camera2D.limit_bottom = limits[3]
	set_process(false)

#Moves player to a new location
func move_player(location:Vector2, direction:Vector2):
	$Movement_Tween.interpolate_property(self, "position", self.position, location, 0.3, 4, 2)
	$Movement_Tween.start()
	#set_facing(direction)
	#look in the direction moved
	if direction.x:
		$AnimationPlayer.play("walk_x")
		if direction.x > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
	if direction.y:
		if direction.y > 0:
			$AnimationPlayer.play("walk_down")
		else:
			$AnimationPlayer.play("walk_up")
	
	dir = direction
	
#set the player to face their direction
func set_facing(direction):
	if direction.x:
		if direction.x > 0:
			sprite.frame = 2
			sprite.flip_h = true
		else:
			sprite.frame = 2
			sprite.flip_h = false
	if direction.y:
		if direction.y > 0:
			sprite.frame = 1
		else:
			sprite.frame = 0
	
#Called when tween finishes
func movement_done(object, key):
	emit_signal("movement_done")
	$AnimationPlayer.stop()
	set_facing(dir)