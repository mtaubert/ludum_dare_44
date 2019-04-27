extends Sprite

onready var demons = [load("res://demon_model/interactable_demons/interactable_demon_1.png")]

var dialoge = {}
var currentDialogKey = ""
var dismissed = false

func _ready():
	$Demon_Talking_Panel/Label.text = ""
	$Demon_Talking_Panel/Accept.disabled = true
	$Demon_Talking_Panel/Decline.disabled = true
	
	Game_Manager.connect("demon_dialog_start", self, "start_dialog")

#Sets the demon to the demon texture and loads the dialoge text, then reads off the opener
func start_dialog(demon, dialogText):
	$Demon_Talking_Panel/Accept.mouse_filter = Control.MOUSE_FILTER_STOP
	$Demon_Talking_Panel/Decline.mouse_filter = Control.MOUSE_FILTER_STOP
	
	$AnimationPlayer.play("demon_arrives")
	dialoge.clear()
	texture = demons[demon-1]
	for key in dialogText:
		dialoge[key] = dialogText[key]
	
	currentDialogKey = "opener"

#Writes the demon dialog to the text box
func demon_talking():
	$Demon_Talking_Panel/Label.text = ""
	
	for c in dialoge[currentDialogKey]["text"]:
		$Demon_Talking_Panel/Label.text += c
		yield(get_tree().create_timer(0.01), "timeout")

#Animation player done, cleans up the labal if dialog is over
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "demon_arrives":
		if dismissed:
			$Demon_Talking_Panel/Label.text = ""
			dismissed = false
		else:
			demon_talking()

func _on_Accept_pressed():
	currentDialogKey = dialoge[currentDialogKey]["accept"]
	if currentDialogKey == null:
		end_dialog()
	else:
		demon_talking()

func _on_Decline_pressed():
	currentDialogKey = dialoge[currentDialogKey]["decline"]
	if currentDialogKey == null:
		end_dialog()
	else:
		demon_talking()

func end_dialog():
	dismissed = true
	$AnimationPlayer.play_backwards("demon_arrives")
	$Demon_Talking_Panel/Accept.disabled = true
	$Demon_Talking_Panel/Decline.disabled = true
	Game_Manager.dialog_over()
