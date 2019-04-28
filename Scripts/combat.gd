extends Node

#player stats stored in game manager

var p_crit = 95
var p_dodge = 0
var e_dodge = 0
var e_crit = 95
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
	pass
	
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