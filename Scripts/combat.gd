extends Node

#player stats stored in game manager
signal player_sacrifice(type, ammount)
signal enemy_risk(type, ammount)
signal enemy_details(data)
signal miss(target)
signal combat_log(text)
signal player_speak(type)
signal enemy_speak(type)
signal offer_bargain(details)

var p_crit = 95
var p_dodge = 0
var e_dodge = 0
var e_crit = 95
var e_risk_mod = 0 # safety from self inflicted wounds
var enemy_data = {}
var enemy_action_definitions = {}
var battleJSON = "res://Assets/monster_actions.json"
var enemy_type = ""
var offer_bargain = false
var e_stunned = false #enemy is stunned
# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

func load_enemy_actions():
	var file = File.new()
	file.open(battleJSON, file.READ)
	var fileJSON = JSON.parse(file.get_as_text())
	
	var tempDialogStore = {}
	
	if fileJSON.error == OK:
		tempDialogStore = fileJSON.result
	
	enemy_data = tempDialogStore
	print(enemy_data)

func set_enemy(enemy_in):
	if enemy_in in enemy_data.keys():
		print("valid enemy")
		enemy_action_definitions = enemy_data[enemy_in]
		emit_signal("enemy_details", enemy_action_definitions)
		
func setup():
	load_enemy_actions()
	#setup enemy and player stats
	print(enemy_data.keys())

func handle_player_action(action):
	#reset temp stats
	p_dodge = 0
	randomize()
	match action:
		"struggle":
			var attack =  randi() % 101
			handle_risk(action, attack)
			return int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
		"dodge":
			p_dodge = 50
		"nab toe":
			var attack =  randi() % 101
			handle_risk(action, attack)
			
			var damage = int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
			if damage > 0:
				if randi()%101 > 25:
					Game_Manager.player_gain("toe", 1)
			
			return damage
		"nick finger":
			var attack =  randi() % 101
			handle_risk(action, attack)
			
			var damage = int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
			if damage > 0:
				if randi()%101 > 25:
					Game_Manager.player_gain("finger", 1)
			
			return damage
		"siphon blood":
			var attack =  randi() % 101
			handle_risk(action, attack)
			
			var bloodSiphoned = int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
			Game_Manager.player_gain("blood", bloodSiphoned)
			return bloodSiphoned
		"stun demon":
			var attack =  randi() % 101
			handle_risk(action, attack)
			var damage = int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
			if damage > 0:
				e_stunned = true
			
			return damage
		_:
			talk(action)
			
func talk(action):
	print("this is some talking")
	if enemy_action_definitions["bargain"]["good"] == action:
		
		offer_bargain = true
		emit_signal("offer_bargain", enemy_action_definitions["bargain"]["offer"])
	elif enemy_action_definitions["bargain"]["bad"] == action: #handle bad action
		pass
	else:
		print("harmless")
		print(enemy_action_definitions["bargain"][action])
	emit_signal("player_speak", enemy_action_definitions["bargain"][action][0])	
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("enemy_speak", enemy_action_definitions["bargain"][action][1])
	
	
func handle_risk(type, roll):
	var risks = Game_Manager.action_definitions[type]["risk"]
	print(risks)
	var cumf = 0
	for item in risks:
		var val = Game_Manager.action_definitions[type]["risk"][item][0]
		print(str(cumf) + " " +str(roll) + " " + str(cumf + val))
		if roll <= cumf + val and roll >= cumf:
			emit_signal("combat_log", "you lose " + str(Game_Manager.action_definitions[type]["risk"][item][1]) + " " + str(item))
			print("ouch")
			#player loses
			emit_signal("player_sacrifice", item, Game_Manager.action_definitions[type]["risk"][item][1])
		cumf += val
	
func handle_enemy_risk(type, roll):
	var risks = Game_Manager.action_definitions[type]["risk"]
	print(risks)
	var cumf = 0
	roll += e_risk_mod
	for item in risks:
		var val = Game_Manager.action_definitions[type]["risk"][item][0]
		print(str(cumf) + " " +str(roll) + " " + str(cumf + val))
		if roll <= cumf + val and roll >= cumf:
			emit_signal("combat_log", "the enemy lost " + str(Game_Manager.action_definitions[type]["risk"][item][1]) + " blood.")
			
			print("ouch")
			#player loses
			emit_signal("enemy_risk", item, Game_Manager.action_definitions[type]["risk"][item][1])
		cumf += val

func handle_enemy_action(action):
	e_dodge = 0
	#reset temporary variables
	print(action)
	match action:
		"splatter", "assault":
			randomize()
			var attack =  randi() % 101
			handle_enemy_risk(action, attack)
			emit_signal("combat_log", "the enemy attacks!")
			return int(enemy_attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
		"dodge":
			e_dodge = 50
			emit_signal("combat_log", "the enemy is trying to dodge.")
		"taunt":
			emit_signal("combat_log", "enemy performs a " + action)
			emit_signal("enemy_speak", enemy_action_definitions["bargain"]["taunt"])
			#the enemy mocks what you shouldn't do
		"spook":
			#the enemies next attack has no risk
			emit_signal("combat_log", "the enemy spooks you, their next attack has no risk")
			e_risk_mod = 100
		"delay", "stunned":
			pass
		_:
			emit_signal("combat_log", "enemy performs a " + action)

func enemy_attack(attack, damage_in):
	var dmg = damage_in
	
	if attack > e_crit:
		emit_signal("combat_log", "the enemey scores a critical hit!")
		print("crit!")
		dmg *= 2
	if attack < p_dodge:
		dmg = 0
		emit_signal("miss", "player")
		emit_signal("combat_log", "the enemy misses you")
		
	emit_signal("combat_log", "the enemy deals " + str(dmg) + " damage!")
	return dmg
	

func attack(attack, damage_in):
	print(damage_in)
	var dmg = damage_in
	
	if attack > p_crit:
		print("crit!")
		emit_signal("combat_log", "A critical hit!")
		dmg *= 2
	if attack < e_dodge:
		dmg = 0
		emit_signal("miss", "enemy")
		emit_signal("combat_log", "you miss the enemy")
	emit_signal("combat_log", "you deal " + str(dmg) + " damage!")
	
	p_crit = 95 #Resets crit chance after attacking
	return dmg