extends Node2D

signal movement_done()
signal start_encounter()

var type = "Player"
var dir = Vector2()
export var speed = 1000
export var limits = [0, 0, 1280, 1024]
onready var sprite = get_node("KinematicBody2D/Sprite")
onready var stats_tween = get_node("Camera2D/CanvasLayer/stats_tween")
var stats_pos = -80
var can_open_menu = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.limit_left = limits[0]
	$Camera2D.limit_top = limits[1]
	$Camera2D.limit_right = limits[2]
	$Camera2D.limit_bottom = limits[3]
	set_process(false)

#Moves player to a new location
func move_player(location:Vector2, direction:Vector2):
	$Movement_Tween.interpolate_property(self, "position", self.position, location, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
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

func play_encounter_start():
	$KinematicBody2D/Character_Effect/AnimationPlayer.play("demon_rising")
	

func _on_demon_rising_finished(anim_name):
	emit_signal("start_encounter")


func _on_stats_tween_tween_completed(object, key):
	can_open_menu = true


func update_blood():
	$Camera2D/CanvasLayer/the_man_stats.update_blood()
	
	
func _on_the_man_stats_blood_paid(ammount):
	var can_pay = Game_Manager.blood > ammount 
	if Game_Manager.blood > ammount:
		Game_Manager.blood -= ammount
	$Camera2D/CanvasLayer/the_man_stats.set_blood(Game_Manager.blood)
	if can_pay:
		return true

func open_menu():
	var the_man = $Camera2D/CanvasLayer/the_man_stats
	var target = the_man.rect_position
	target.x = 80
	stats_tween.interpolate_property(the_man, "rect_position", the_man.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	stats_tween.start()
	$Camera2D/CanvasLayer/the_man_stats.toggle_buttons(true)