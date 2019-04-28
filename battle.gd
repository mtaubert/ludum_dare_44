extends Control

var show_the_man = false
onready var tween = get_node("CanvasLayer/the_man_stats/man_tween")

onready var backdrop_0 = load("res://Assets/battle_backdrop.png")
onready var backdrop_1 = load("res://Assets/battle_backdrop_2.png")
# Called when the node enters the scene tree for the first time.

var menu_queue = []
var menu_loc = Vector2(524, 400)
var menu_hide_loc = Vector2(1224, 400)
var sub_menu_loc = Vector2(524, 640)
func _ready():
	randomize()
	
	if Game_Manager.specificEnemy == null:
		$enemy_character/enemy.frames = Demon_Manager.randomEncounterDemons[String((randi()%2)+1)]["encounter_animations"]
	else:
		#Grabs the current demon and loads their encounter frames
		$enemy_character/enemy.frames = Demon_Manager.demons[String(Game_Manager.specificEnemy)]["encounter_animations"]
	
	$TextureRect.texture = get("backdrop_" + str(randi() % 2))


func _on_sacrifice_pressed():
	show_the_man = not show_the_man
	if show_the_man:
		$CanvasLayer/the_man_stats.toggle_buttons(true)
		var target = $CanvasLayer/the_man_stats.rect_position
		target.x = 80
		tween.interpolate_property($CanvasLayer/the_man_stats, "rect_position", $CanvasLayer/the_man_stats.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	else:
		
		$CanvasLayer/the_man_stats.toggle_buttons(false)
		var target = $CanvasLayer/the_man_stats.rect_position
		target.x = -200
		tween.interpolate_property($CanvasLayer/the_man_stats, "rect_position", $CanvasLayer/the_man_stats.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

#hide the combat meu and reveal the selected menu
func hide_menu(type):
	
	hide_the_man()
	var menu = get_node(type + "_menu")
	var target = Vector2()
	match type:
		"battle":
			target = menu_hide_loc
		_:
			target = sub_menu_loc
	$menu_tween.interpolate_property(menu, "rect_position", menu.rect_position,  target, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$menu_tween.start()

func _on_fight_pressed():
	hide_menu("battle")
	menu_queue.append("fight")
	#hit_enemy(13)
	#blood_count += 20
	#blood_val = blood_val %101
	#$CanvasLayer/the_man_stats.set_blood(blood_val)


func _on_flee_pressed():
	Game_Manager.end_encounter()


func _on_the_man_stats_blood_paid(ammount):
	if Game_Manager.blood > ammount:
		Game_Manager.blood -= ammount
	$CanvasLayer/the_man_stats.set_blood(Game_Manager.blood)

func hit_enemy(damage):
	$enemy_character/enemy_health/damage_tween.interpolate_property($enemy_character/enemy_health, "value", $enemy_character/enemy_health.value,  $enemy_character/enemy_health.value - damage, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	$enemy_character/enemy_health/damage_tween.start()

func _on_damage_tween_tween_completed(object, key):
	#check enemy health for low health or death
	print($enemy_character/enemy_health.value)
	if $enemy_character/enemy_health.value <= 0:
		Game_Manager.end_encounter()
	if $enemy_character/enemy_health.value <= 10:
		$enemy_character/enemy_health/AnimationPlayer.play("low_health_enemy")
	
func hide_the_man():
	if show_the_man:
		_on_sacrifice_pressed()


func _on_talk_pressed():
	hide_menu("battle")
	menu_queue.append("talk")


func _on_talk_menu_back(this):
	print(this)
	hide_menu("talk")
	menu_queue.append("battle")



func _on_fight_menu_back(this):
	print(this)
	hide_menu("fight")
	menu_queue.append("battle")


# brinc the named menu into the view spot
func reveal_menu(name):
	hide_the_man()
	var menu = get_node(name + "_menu")
	$menu_tween.interpolate_property(menu, "rect_position", menu.rect_position,  menu_loc, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$menu_tween.start()


func _on_menu_tween_tween_completed(object, key):
	#check the menu queue for jobs and reveal
	if menu_queue:
		reveal_menu(menu_queue.back())
		menu_queue.clear()
