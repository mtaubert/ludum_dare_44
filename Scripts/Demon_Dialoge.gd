extends Sprite

var currentDemon = ""

var dialoge = {}
var currentDialogKey = ""
var dismissed = false

func _ready():
	$Demon_Talking_Panel/Label.text = ""
	hide_buttons()
	
	Game_Manager.connect("demon_dialog_start", self, "start_dialog")

#Sets the demon to the demon texture and loads the dialoge text, then reads off the opener
func start_dialog(demonID):
	show()
	hide_buttons()
	$AnimationPlayer.play("demon_arrives")
	
	currentDemon = demonID
	texture = Demon_Manager.demons[String(demonID)]["dialog_animations"]
	
	dialoge.clear()
	for key in Demon_Manager.demons[String(demonID)]["dialog"]:
		dialoge[key] = Demon_Manager.demons[String(demonID)]["dialog"][key]
	
	currentDialogKey = "opener"

#Writes the demon dialog to the text box
func demon_talking():
	$Demon_Talking_Panel/Label.text = ""
	for c in dialoge[currentDialogKey]["text"]:
		$Demon_Talking_Panel/Label.text += c
		yield(get_tree().create_timer(0.01), "timeout")
	
	show_buttons()

func show_buttons():
	if dialoge[currentDialogKey]["accept_text"] != null:
		$Demon_Talking_Panel/Accept.text = dialoge[currentDialogKey]["accept_text"]
		$Demon_Talking_Panel/Accept.show()
		
		if dialoge[currentDialogKey]["decline_text"] != null:
			$Demon_Talking_Panel/Decline.text = dialoge[currentDialogKey]["decline_text"]
			$Demon_Talking_Panel/Decline.show()
	else:
		yield(get_tree().create_timer(0.5), "timeout")
		end_dialog()

func hide_buttons():
	$Demon_Talking_Panel/Accept.hide()
	$Demon_Talking_Panel/Decline.hide()

#Animation player done, cleans up the labal if dialog is over
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "demon_arrives":
		if dismissed:
			$Demon_Talking_Panel/Label.text = ""
			dismissed = false
			hide()
			Game_Manager.dialog_over()
		else:
			demon_talking()

func _on_Accept_pressed():
	hide_buttons()
	currentDialogKey = dialoge[currentDialogKey]["accept"]
	match_current_key()

func _on_Decline_pressed():
	hide_buttons()
	currentDialogKey = dialoge[currentDialogKey]["decline"]
	match_current_key()

#Compare current key to predefined values
func match_current_key():
	match currentDialogKey:
		null: #Conversation is over
			end_dialog()
		1.0, 1, "1": #Fight, dunno what type this comes out as so here's all of them
			Game_Manager.start_encounter_against(currentDemon)
		_:
			demon_talking()

func end_dialog():
	dismissed = true
	$AnimationPlayer.play_backwards("demon_arrives")