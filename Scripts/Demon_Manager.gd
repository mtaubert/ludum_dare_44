extends Node


var demons = {
	"1": {
		"dialog": {},
		"dialog_animations": load("res://demon_model/interactable_demons/interactable_demon_1.png"),
		"map_animations": load("res://demon_model/interactable_demons/interactible_demon_1.tres"),
		"name": "Wiggles",
		"encounter_animations": load("res://demon_model/wiggles_sheet.tres")
	},
	"2": {
		"dialog": {},
		"dialog_animations": load("res://demon_model/interactable_demons/interactable_demon_2.png"),
		"map_animations": load("res://demon_model/interactable_demons/interactible_demon_2.tres"),
		"name": "Wranque",
		"encounter_animations": null
	}
}

var randomEncounterDemons = {
	"1": {
		"encounter_animations": load("res://demon_model/commandeer_sheet.tres")
	},
	"2": {
		"encounter_animations": load("res://demon_model/keeper_demon_sheet.tres")
	}
}

var defaultDialog = {
	"opener": {
		"text": "Leave me alone!",
		"accept": null,
		"decline": null,
		"accept_text": null,
		"decline_text": null
	}
}

var dialogJSON = "res://Assets/demon_data.json"

func _ready():
	load_dialog()

func load_dialog():
	var tempDialogStore = {}
	
	var file = File.new()
	file.open(dialogJSON, file.READ)
	var fileJSON = JSON.parse(file.get_as_text())
	
	if fileJSON.error == OK:
		tempDialogStore = fileJSON.result
	
	#Loads each demon's dialog
	var demonsWithDialog = []
	for demonID in tempDialogStore:
		if demons.has(demonID):
			demons[demonID]["dialog"] = tempDialogStore[demonID]
			demonsWithDialog.append(demonID)
	
	#Any demons that don't have any dialog get a default set
	for demon in demons:
		if not demon in demonsWithDialog:
			demons[demon]["dialog"] = defaultDialog