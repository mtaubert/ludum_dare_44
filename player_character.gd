extends Node2D

signal movement_done()

var dir = Vector2()
export var speed = 1000
export var limits = [0, 0, 1280, 1024]
onready var sprite = get_node("KinematicBody2D/Sprite")

# Called when the node enters the scene tree for the first time.
func _ready():
	$KinematicBody2D/Camera2D.limit_left = limits[0]
	$KinematicBody2D/Camera2D.limit_top = limits[1]
	$KinematicBody2D/Camera2D.limit_right = limits[2]
	$KinematicBody2D/Camera2D.limit_bottom = limits[3]
	set_process(false)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dir = Vector2(0,0)
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	dir = dir.normalized()
	$KinematicBody2D.move_and_slide(dir * speed)

#Moves player to a new location
func move_player(location:Vector2, direction:Vector2):
	$Movement_Tween.interpolate_property(self, "position", self.position, location, 0.3, 4, 2)
	$Movement_Tween.start()
	
	#look in the direction moved
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