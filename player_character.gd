extends Node2D

signal movement_done()

var type = "Player"
var dir = Vector2()
export var speed = 1000
export var limits = [0, 0, 1280, 1024]
onready var sprite = get_node("KinematicBody2D/Sprite")
onready var stats_tween = get_node("Camera2D/CanvasLayer/stats_tween")
var stats_pos = -80
var can_open_menu = true

export var blood_count = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.limit_left = limits[0]
	$Camera2D.limit_top = limits[1]
	$Camera2D.limit_right = limits[2]
	$Camera2D.limit_bottom = limits[3]
	set_process(false)

#Moves player to a new location
func move_player(location:Vector2, direction:Vector2):
	$Movement_Tween.interpolate_property(self, "position", self.position, location, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
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
	
#show the man/ hide the man
func toggle_stats_view():
	if can_open_menu:
		can_open_menu = false
		var the_man = $Camera2D/CanvasLayer/the_man_stats
		var target = the_man.rect_position
		if stats_pos == -80:
			stats_pos = 80
			the_man.toggle_buttons(true)
		else:
			
			the_man.toggle_buttons(false)
			stats_pos = -80
		target.x = stats_pos
		stats_tween.interpolate_property(the_man, "rect_position", the_man.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
		stats_tween.start()
	

func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer2D.play()



func _on_stats_tween_tween_completed(object, key):
	can_open_menu = true


func _on_the_man_stats_blood_paid(ammount):
	if blood_count > ammount:
		blood_count -= ammount
	$Camera2D/CanvasLayer/the_man_stats.set_blood(blood_count)
