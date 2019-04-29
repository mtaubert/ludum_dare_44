extends Control

onready var backdrop_0 = load("res://Assets/battle_backdrop.png")
onready var backdrop_1 = load("res://Assets/battle_backdrop_2.png")
# Called when the node enters the scene tree for the first time.

#player_damagesprites
onready var player10 = load("res://character_model/player_battle_sprite.png")
onready var player9 = load("res://character_model/player_battle_sprite_dmg_1.png")
onready var player8 = load("res://character_model/player_battle_sprite_dmg_2.png")
onready var player7 = load("res://character_model/player_battle_sprite_dmg_3.png")
onready var player6 = load("res://character_model/player_battle_sprite_dmg_4.png")
onready var player5 = load("res://character_model/player_battle_sprite_dmg_5.png")
onready var player4 = load("res://character_model/player_battle_sprite_dmg_6.png")
onready var player3 = load("res://character_model/player_battle_sprite_dmg_7.png")
onready var player2 = load("res://character_model/player_battle_sprite_dmg_8.png")
onready var player1 = load("res://character_model/player_battle_sprite_dmg_9.png")

var menu_queue = []
var menu_loc = Vector2(524, 400)
var menu_hide_loc = Vector2(1224, 400)
var sub_menu_loc = Vector2(524, 640)

var button = load("res://Scenes/Prefabs/battle_button.tscn")

var turn: int  = 0#tracks the combat turn
var player_active = true

var current_menu = "battle"
var enemy = ""
var enemy_attacks = 0

func _ready():
	update_player_dmg()
	randomize()
	
	if Game_Manager.specificEnemy == null:
		var randomDemon = String((randi()%(Demon_Manager.randomEncounterDemons.size()))+1)
		print(randomDemon)
		$enemy_character/enemy.frames = Demon_Manager.randomEncounterDemons[randomDemon]["encounter_animations"]
		$enemy_character/enemy.animation = "default"
		match randomDemon:
			"1":
				enemy = "commandeer"
			"2":
				enemy = "spectre"
			"3":
				enemy = "behold"
			"4":
				enemy = "eyes_and_holes"
			_:
				print("demon out of range!")
	else:
		#Grabs the current demon and loads their encounter frames
		$enemy_character/enemy.frames = Demon_Manager.demons[String(Game_Manager.specificEnemy)]["encounter_animations"]
		$enemy_character/enemy.animation = "default"
		print(Game_Manager.specificEnemy)
		match Game_Manager.specificEnemy:
			1:
				enemy = "wiggles"
			_:
				print("demon out of range!")
	
	$TextureRect.texture = get("backdrop_" + str(randi() % 2))
	
	init_player_actions()
	
	combat.connect("player_sacrifice", self, "player_sacrifice")
	combat.connect("enemy_details", self, "setup_enemy")
	combat.connect("enemy_risk", self, "enemy_risk")
	combat.connect("miss", self, "miss")
	combat.connect("combat_log", self, "combat_log")
	combat.connect("enemy_speak", self, "enemy_speak")
	combat.connect("player_speak", self, "player_speak")
	combat.connect("offer_bargain", self, "bargain")
	combat.set_enemy(enemy)
	
	
func setup_enemy(details):
	print(details)
	$enemy_character/enemy_health.max_value = details["stats"]["health"]
	$enemy_character/enemy_health.value = details["stats"]["health"]
	print($enemy_character/enemy_health.value)
	enemy_attacks = details["actions"].keys()
	print(enemy_attacks)
	
#go through for each valid action in the game managerand add a button
func init_player_actions():
	for item in Game_Manager.attack_actions:
		var action = button.instance()
		action.init(item)
		$fight_menu.add_button(action)
		
	for item in Item_Manager.get_unique_items():
		var action = button.instance()
		action.init(Item_Manager.items[item]["effect"])
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
	elif action in Game_Manager.attack_actions or action in Game_Manager.item_actions:
		$fight_menu.show_details(action)
	#update the details viewer
	

#hide the combat meu and reveal the selected menu
func hide_menu(type):
	var menu = get_node(type + "_menu")
	var target = Vector2()
	match type:
		"battle":
			target = menu_hide_loc
		_:
			target = sub_menu_loc
	$menu_tween.interpolate_property(menu, "rect_position", menu.rect_position,  target, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$menu_tween.start()
	empty_combat_log()

func _on_fight_pressed():
	hide_menu("battle")
	menu_queue.append("fight")
	#hit_enemy(13)
	#blood_count += 20
	#blood_val = blood_val %101
	#$CanvasLayer/the_man_stats.set_blood(blood_val)


func _on_flee_pressed():
	end_battle()

func update_player_dmg():
	var blood = Game_Manager.blood
	if int(blood/10) > 0:
		$player.texture = get("player" + str(int(blood/10)))

func _on_the_man_stats_blood_paid(ammount):
	if Game_Manager.blood > ammount:
		Game_Manager.blood -= ammount
	$CanvasLayer/the_man_stats.set_blood(Game_Manager.blood)
	update_player_dmg()

func hit_enemy(damage):
	$enemy_character/enemy_health/damage_tween.interpolate_property($enemy_character/enemy_health, "value", $enemy_character/enemy_health.value,  $enemy_character/enemy_health.value - damage, 0.2, Tween.TRANS_BACK, Tween.EASE_IN)
	$enemy_character/enemy_health/damage_tween.start()
	$AudioStreamPlayersfx.stream = load("res://Assets/audio/minor_dmg.wav")
	$AudioStreamPlayersfx.play()

func _on_damage_tween_tween_completed(object, key):
	#check enemy health for low health or death
	print("enemy health")
	print($enemy_character/enemy_health.value)
	if $enemy_character/enemy_health.value <= 0:
		enemy_death()
		#Game_Manager.end_encounter()
	if $enemy_character/enemy_health.value <= 10:
		$enemy_character/enemy_health/AnimationPlayer.play("low_health_enemy")
	
func enemy_death():
	$enemy_character/enemy/combat_animator.play("enemy_defeated")
		


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
	var menu = get_node(name + "_menu")
	$menu_tween.interpolate_property(menu, "rect_position", menu.rect_position,  menu_loc, 0.2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$menu_tween.start()
	menu.focus_menu()


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
		$CanvasLayer/the_man_stats.disable_buttons()
		if $enemy_character/enemy_health/AnimationPlayer.current_animation == "bargain":
			$enemy_character/enemy_health/AnimationPlayer.stop()
			$enemy_character/enemy_health.tint_progress = Color("ff0000")
	#hide ui
	hide_menu(current_menu)
	menu_queue.append("battle")

func unlock_ui():
	for button in get_tree().get_nodes_in_group("battle_button"):
		button.disabled = false
	for button in get_tree().get_nodes_in_group("talk_button"):
		button.disabled = false
	for item in $battle_menu/VBoxContainer/HBoxContainer.get_children():
		item.disabled = false
		#$CanvasLayer/the_man_stats.enable_buttons()
	#reveal ui
	#reveal_menu("battle")
	
func end_battle():
	$AnimationPlayer.play("battle_end")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "battle_end":
		if Game_Manager.blood <= 0:
			Game_Manager.player_death()
		else:
			Game_Manager.end_encounter()
		
func player_sacrifice(type, ammount):
	$AudioStreamPlayersfx.stream = load("res://Assets/audio/demon_damage.wav")
	Game_Manager.player_sacrifice(type, ammount)
	$CanvasLayer/the_man_stats.set_blood(Game_Manager.blood)
	update_player_dmg()
	player_log("ow!")
	yield(get_tree().create_timer(0.5), "timeout")
	enemy_log("ahh precious " + type + "!")
	
	yield(get_tree().create_timer(5), "timeout")
	hide_player_log()
	hide_enemy_log()
	
func enemy_risk(type, ammount):
	hit_enemy(ammount)
	print("enemy took recoil")
	#enemy_log("ahh curses!")
	##yield(get_tree().create_timer(5), "timeout")
	#hide_enemy_log()
	
func player_log(text):
	$player/speech.visible = true
	$player/speech/RichTextLabel.text = ""
	for c in text:
		$player/speech/RichTextLabel.text += c
		yield(get_tree().create_timer(0.01), "timeout")
	return true
	
func enemy_log(text):
	$enemy_character/enemy_speech.visible = true
	$enemy_character/enemy_speech/RichTextLabel.text = ""
	for c in text:
		$enemy_character/enemy_speech/RichTextLabel.text += c
		yield(get_tree().create_timer(0.01), "timeout")
		
func combat_log(text):
	$battle_menu/VBoxContainer/combat_log/RichTextLabel.text += text + " "

func empty_combat_log():
	$battle_menu/VBoxContainer/combat_log/RichTextLabel.text = ""

func hide_player_log():
	$player/speech.visible = false		
	
func hide_enemy_log():
	$enemy_character/enemy_speech.visible = false	
	
func miss(target):
	match target:
		"player":
			enemy_log("curses he dodged me!")
			yield(get_tree().create_timer(5), "timeout")
		"enemy":
			player_log("damn I missed")
			yield(get_tree().create_timer(5), "timeout")
		_:
			print("error in miss signal")
	hide_player_log()
	hide_enemy_log()
	
	
func bargain(details):
	print(details)
	$enemy_character/enemy_health/AnimationPlayer.play("bargain")
	$CanvasLayer/the_man_stats.enable_button(details[0], details[1])
	print(details[1])
	combat_log("you will be spared in exchange for " + str(details[1]) + " " + (details[0]))
	
func check_player_death():
	if Game_Manager.blood <= 0:
		end_battle()
##--------------------------------------------------------------------
##battle logic
##--------------------------------------------------------------------
#sacrifice and flee are not handled logic side yet
#
##track the turn, take a user action and pass
#define each of the combat actions
func player_action(action):
	check_player_death()
	if player_active:
		match action:
			"struggle":
				$player/player_combat_animator.play("struggle")
			"dodge":
				$player/player_combat_animator.play("dodge")
			_:
				#if not a predefined action just pass
				$player/player_combat_animator.play(action)
		
		lock_ui()
	else:
		print("inactive, cant take an action")
	
func enemy_action(action):
	print("--enemy action--")
	print(action)
	
	if combat.offer_bargain:
		combat.offer_bargain = false
		action = "delay"
	if combat.e_stunned:
		combat.e_stunned = false
		action = "stunned"
	#delay half a second
	yield(get_tree().create_timer(0.5), "timeout")
	#check if the enemy is still alive
	if $enemy_character/enemy_health.value > 0:
		match action:
			"spook":
				$enemy_character/enemy/combat_animator.play(action)
			"dodge":
				$enemy_character/enemy/combat_animator.play(action)
			"assault":
				$enemy_character/enemy/combat_animator.play(action)
			"taunt":
				$enemy_character/enemy/combat_animator.play(action)
			"splatter":
				$enemy_character/enemy/combat_animator.play(action)
			_:
				print("undefined action")
				$enemy_character/enemy/combat_animator.play("delay")
			#pass_turn()
	
	
func pass_turn():
	print("pass turn")
	print(turn)
	if turn % 2 == 1:
		player_active = true
		unlock_ui()
		#unlock_ui
		#its the players go
	else:
		player_active = false
		#its the enemies go
		#choose a random action from the availiable attacks
		randomize()
		enemy_action(enemy_attacks[randi()%len(enemy_attacks)])
		#lock ui
		
	turn += 1
#---------------------------------------
#enemy actions
#---------------------------------------
func spook():
	pass
	
func enemy_speak(type):
	enemy_log(type)
	
func player_speak(type):
	player_log(type)

#demon anim finished pass the turn back
func _on_combat_animator_animation_finished(anim_name):
	match anim_name:
		"enemy_defeated":
			end_battle()
		_:
			var damage = combat.handle_enemy_action(anim_name)
			if damage:
				player_sacrifice("blood", damage)
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


		


func _on_the_man_stats_paid_tribute(valid):
	if valid:
		print("paid the bargain cost")
		end_battle()
	else:
		print("cant afford the bargain")
		player_log("I don't have enough!")
