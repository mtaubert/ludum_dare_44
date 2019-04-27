extends Node2D

signal movement_done()

var dir = Vector2()
export var speed = 1000
export var limits = [0, 0, 1280, 1024]

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
func move_player(location:Vector2):
	$Movement_Tween.interpolate_property(self, "position", self.position, location, 0.3, 4, 2)
	$Movement_Tween.start()

#Called when tween finishes
func movement_done():
	emit_signal("movement_done")