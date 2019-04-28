extends Node

#player stats stored in game manager
signal player_sacrifice(type, ammount)
signal enemy_risk(type, ammount)
signal enemy_details(data)
signal miss(target)
var p_crit = 95
var p_dodge = 0
var e_dodge = 0
var e_crit = 95

var enemy_data = {}
var enemy_action_definitions = {}
var battleJSON = "res://Assets/monster_actions.json"
var enemy_type = ""
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
	match action:
		"struggle":
			randomize()
			var attack =  randi() % 101
			handle_risk(action, attack)
			return int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
		"dodge":
			p_dodge = 50
		_:
			pass
	
func handle_risk(type, roll):
	var risks = Game_Manager.action_definitions[type]["risk"]
	print(risks)
	var cumf = 0
	for item in risks:
		var val = Game_Manager.action_definitions[type]["risk"][item][0]
		print(str(cumf) + " " +str(roll) + " " + str(cumf + val))
		if roll <= cumf + val and roll >= cumf:
			print("ouch")
			#player loses
			emit_signal("player_sacrifice", item, Game_Manager.action_definitions[type]["risk"][item][1])
		cumf += val
	
func handle_enemy_risk(type, roll):
	var risks = Game_Manager.action_definitions[type]["risk"]
	print(risks)
	var cumf = 0
	for item in risks:
		var val = Game_Manager.action_definitions[type]["risk"][item][0]
		print(str(cumf) + " " +str(roll) + " " + str(cumf + val))
		if roll <= cumf + val and roll >= cumf:
			print("ouch")
			#player loses
			emit_signal("enemy_risk", item, Game_Manager.action_definitions[type]["risk"][item][1])
		cumf += val

func handle_enemy_action(action):
	e_dodge = 0
	#reset temporary variables
	match action:
		"splatter", "assault":
			randomize()
			var attack =  randi() % 101
			handle_enemy_risk(action, attack)
			return int(enemy_attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
		"dodge":
			e_dodge = 50
		_:
			pass

func enemy_attack(attack, damage_in):
	var dmg = damage_in
	
	if attack > e_crit:
		print("crit!")
		dmg *= 2
	if attack < p_dodge:
		dmg = 0
		emit_signal("miss", "player")
	return dmg
	

func attack(attack, damage_in):
	print(damage_in)
	var dmg = damage_in
	
	if attack > p_crit:
		print("crit!")
		dmg *= 2
	if attack < e_dodge:
		dmg = 0
		emit_signal("miss", "enemy")
	return dmg