extends Sprite

export var demonID = 1
var type = "Item"
var thisItem
var itemAmmount

signal picked_up()

func _ready():
	$Highlight.hide()

func setup(item, ammount):
	thisItem = item
	itemAmmount = ammount
	
	if item in Item_Manager.items.keys():
		texture = Item_Manager.items[item]["image"]
		scale = Vector2(0.1,0.1)
	else:
		texture = Item_Manager.currencies[item]
		scale = Vector2(0.2,0.2)

func interact():
	Item_Manager.give_item(thisItem, itemAmmount)
	emit_signal("picked_up", position)
	Game_Manager.update_tooltip(thisItem, itemAmmount)

func highlight():
	$Highlight.show()
	$AnimationPlayer.play("Highlight")

func unhighlight():
	$Highlight.hide()
	$AnimationPlayer.stop()