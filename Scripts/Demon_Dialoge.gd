extends Sprite

var currentDemon = ""

var dialoge = {}
var currentDialogKey = ""
var dismissed = false

var bargaining = false

func _ready():
	$Demon_Talking_Panel/Text.text = ""
	hide_buttons()
	
	Game_Manager.connect("demon_dialog_start", self, "start_dialog")

#Sets the demon to the demon texture and loads the dialoge text, then reads off the opener
func start_dialog(demonID):
	show()
	
	setup_shop(Demon_Manager.demons[String(demonID)]["bargain_items"])
	hide_buttons()
	$AnimationPlayer.play("demon_arrives")
	
	currentDemon = demonID
	$Name.text = Demon_Manager.demons[String(demonID)]["name"]
	texture = Demon_Manager.demons[String(demonID)]["dialog_animations"]
	
	dialoge.clear()
	for key in Demon_Manager.demons[String(demonID)]["dialog"]:
		dialoge[key] = Demon_Manager.demons[String(demonID)]["dialog"][key]
	
	currentDialogKey = "opener"

onready var shopItem = load("res://Scenes/Prefabs/Shop_Item.tscn")

#Addes items to the shop
func setup_shop(items):
	for item in items:
		if not Item_Manager.playerInventory.has(item):
			var newShopItem = shopItem.instance()
			newShopItem.setup(item)
			$Shop.add_child(newShopItem)
			

#Writes the demon dialog to the text box
func demon_talking():
	$Demon_Talking_Panel/Text.text = ""
	print_dialog(dialoge[currentDialogKey]["text"])
	

func print_dialog(text):
	for c in text:
		$Demon_Talking_Panel/Text.text += c
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
			$Demon_Talking_Panel/Text.text = ""
			dismissed = false
			hide()
			Game_Manager.dialog_over()
		else:
			demon_talking()
	elif anim_name == "bargain_begins":
		if not bargaining:
			demon_talking()
		else:
			print_dialog(dialoge["shop"]["text"])

func _on_Accept_pressed():
	if not bargaining:
		hide_buttons()
		#currentDialogKey = dialoge[currentDialogKey]["accept"]
		match_current_key(dialoge[currentDialogKey]["accept"])
	else:
		hide_shop()

func _on_Decline_pressed():
	hide_buttons()
	#currentDialogKey = dialoge[currentDialogKey]["decline"]
	match_current_key(dialoge[currentDialogKey]["decline"])

#Compare current key to predefined values
func match_current_key(key):
	match key:
		null: #Conversation is over
			end_dialog()
		1.0, 1, "1": #Fight, dunno what type this comes out as so here's all of them
			Game_Manager.start_encounter_against(currentDemon)
		2.0,2,"2":
			show_shop()
		_:
			currentDialogKey = key
			demon_talking()

func show_shop():
	$Demon_Talking_Panel/Text.text = ""
	$Demon_Talking_Panel/Accept.show()
	$Demon_Talking_Panel/Accept.text = "Done looking"
	$AnimationPlayer.play("bargain_begins")
	bargaining = true

func hide_shop():
	$Demon_Talking_Panel/Text.text = ""
	hide_buttons()
	$AnimationPlayer.play_backwards("bargain_begins")
	bargaining = false

func end_dialog():
	dismissed = true
	for child in $Shop.get_children():
		child.queue_free()
	$AnimationPlayer.play_backwards("demon_arrives")