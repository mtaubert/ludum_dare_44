extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Item_Manager.connect("item_purchased", self, "update_tips")
	update_tips()

func update_tips():
	var items = get_tree().get_nodes_in_group("inventory")
	print(items)
	for item in items:
		item.connect("tooltip", self, "tooltip")

func tooltip(text):
	$tooltip.visible = true
	$tooltip/Text.text = text
	
func clear():
	$tooltip/Text.text = ""
	
func hide_tip():
	$tooltip.visible = false
	
	