extends Node

#player stats stored in game manager
signal player_sacrifice(type, ammount)

var p_crit = 95
var p_dodge = 0
var e_dodge = 0
var e_crit = 95

var enemy_actions = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init():
	pass
	#setup enemy and player stats

func handle_player_action(action):
	match action:
		"struggle":
			randomize()
			var attack =  randi() % 101
			handle_risk(action, attack)
			return int(attack(attack, Game_Manager.action_definitions[action]["stats"]["damage"]))
		"dodge":
			pass
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
	

func handle_enemy_action(action):
	pass

func attack(attack, damage_in):
	print(damage_in)
	var dmg = damage_in
	
	if attack > p_crit:
		print("crit!")
		dmg *= 2
	if attack < e_dodge:
		dmg = 0
	return dmg