extends Sprite

var dialoge = "Puny mortal"
var dismissed = false

func _ready():
	$Demon_Talking_Panel/Label.text = ""
	$AnimationPlayer.play("demon_arrives")
	$Demon_Talking_Panel/Accept.disabled = true
	$Demon_Talking_Panel/Decline.disabled = true

func demon_talking():
	$Demon_Talking_Panel/Label.text = ""
	for c in dialoge:
		$Demon_Talking_Panel/Label.text += c
		yield(get_tree().create_timer(0.01), "timeout")
	
	$Demon_Talking_Panel/Accept.disabled = false
	$Demon_Talking_Panel/Decline.disabled = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "demon_arrives":
		if dismissed:
			$Demon_Talking_Panel/Label.text = ""
			dismissed = false
		else:
			demon_talking()

func _on_Accept_pressed():
	dialoge = "You can do better than that"
	demon_talking()

func _on_Decline_pressed():
	dismissed = true
	$AnimationPlayer.play_backwards("demon_arrives")
	$Demon_Talking_Panel/Accept.disabled = true
	$Demon_Talking_Panel/Decline.disabled = true
