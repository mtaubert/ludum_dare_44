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

var button = load("res://Scenes/Prefabs/battle_button.tscn")

var turn: int  = 0#tracks the combat turn
var player_active = true

var current_menu = "battle"


func _ready():
	randomize()
	
	if Game_Manager.specificEnemy == null:
		var randomDemon = String((randi()%(Demon_Manager.randomEncounterDemons.size()))+1)
		print(randomDemon)
		$enemy_character/enemy.frames = Demon_Manager.randomEncounterDemons[randomDemon]["encounter_animations"]
		$enemy_character/enemy.animation = "default"
	else:
		#Grabs the current demon and loads their encounter frames
		$enemy_character/enemy.frames = Demon_Manager.demons[String(Game_Manager.specificEnemy)]["encounter_animations"]
		$enemy_character/enemy.animation = "default"
	
	$TextureRect.texture = get("backdrop_" + str(randi() % 2))
	
	init_player_actions()

#go through for each valid action in the game managerand add a button
func init_player_actions():
	for item in Game_Manager.attack_actions:
		var action = button.instance()
		action.init(item)
		$fight_menu.add_button(action)
		
	for item in Game_Manager.talk_actions:
		var action = button.instance()
		action.init(item)
		$talk_menu.add_button(action)
		
	for button in get_tree().get_nodes_in_group("battle_button"):
		button.connect("battle_action",self,"battle_action")
		button.connect("show_details",self,"show_details")
		
		
func battle_action(action):
	print(action)
	player_action(action)
	#excecute the chosen battle action then pass the turn
	
func show_details(action):
	if action in Game_Manager.talk_actions:
		$talk_menu.show_details(action)
	if action in Game_Manager.attack_actions:
		$fight_menu.show_details(action)
	#update the details viewer
	
	
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
	hide_the_man()
	end_battle()


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
		enemy_death()
		#Game_Manager.end_encounter()
	if $enemy_character/enemy_health.value <= 10:
		$enemy_character/enemy_health/AnimationPlayer.play("low_health_enemy")
	
func enemy_death():
	$enemy_character/enemy/combat_animator.play("enemy_defeated")
		
func hide_the_man():
	if show_the_man:
		_on_sacrifice_pressed()


func _on_talk_pressed():
	hide_menu("battle")
	menu_queue.append("talk")


func _on_talk_menu_back(this):
	hide_menu("talk")
	menu_queue.append("battle")



func _on_fight_menu_back(this):
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
		current_menu = menu_queue.back()
		menu_queue.clear()
		
		
func lock_ui():
	for button in get_tree().get_nodes_in_group("battle_button"):
		button.disabled = true
	for button in get_tree().get_nodes_in_group("talk_button"):
		button.disabled = true
	for item in $battle_menu/VBoxContainer/HBoxContainer.get_children():
		item.disabled = true
	for item in $battle_menu/VBoxContainer/HBoxContainer2.get_children():
		item.disabled = true
		$CanvasLayer/the_man_stats.disable_buttons()
	#hide ui
	hide_menu(current_menu)

func unlock_ui():
	for button in get_tree().get_nodes_in_group("battle_button"):
		button.disabled = false
	for button in get_tree().get_nodes_in_group("talk_button"):
		button.disabled = false
	for item in $battle_menu/VBoxContainer/HBoxContainer.get_children():
		item.disabled = false
	for item in $battle_menu/VBoxContainer/HBoxContainer2.get_children():
		item.disabled = false
		$CanvasLayer/the_man_stats.enable_buttons()
	#reveal ui
	reveal_menu("battle")
	
func end_battle():
	$AnimationPlayer.play("battle_end")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "battle_end":
		Game_Manager.end_encounter()
##--------------------------------------------------------------------
##battle logic
##--------------------------------------------------------------------
#sacrifice and flee are not handled logic side yet
#
##track the turn, take a user action and pass
#define each of the combat actions
func player_action(action):
	if player_active:
		match action:
			"struggle":
				$player/player_combat_animator.play("struggle")
			"dodge":
				$player/player_combat_animator.play("dodge")
			_:
				#if not a predefined action just pass
				pass_turn()
		
		lock_ui()
	else:
		print("inactive, cant take an action")
	
func enemy_action(action):
	match action:
		"spook":
			spook()
		_:
			pass
	
	
func pass_turn():
	print(turn)
	if turn % 2 == 1:
		player_active = true
		unlock_ui()
		#unlock_ui
		#its the players go
	else:
		player_active = false
		#its the enemies go
		enemy_action("spook")
		#lock ui
		
	turn += 1
#---------------------------------------
#enemy actions
#---------------------------------------
func spook():
	$enemy_character/enemy/combat_animator.play("delay")

#demon anim finished pass the turn back
func _on_combat_animator_animation_finished(anim_name):
	match anim_name:
		"enemy_defeated":
			end_battle()
		_:
			combat.handle_enemy_action(anim_name)
			pass_turn()

#process the player attack and pass the turn
func _on_player_combat_animator_animation_finished(anim_name):
	var dmg = combat.handle_player_action(anim_name)
	if dmg:
		hit_enemy(dmg)
	"""match anim_name:
		"struggle":
			hit_enemy(13)
		"dodge":
			pass
		_:
			pass
	"""
	pass_turn()


		
