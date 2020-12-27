extends Label

export(NodePath) var matchnum_node
#export(NodePath) var skins_node

func select():
	# Create Scene
	var round_inst = load("res://Menus/RoundManager.tscn").instance()
	round_inst.init(get_node(matchnum_node).get_matchnum(), [])
	get_tree().get_root().call_deferred("add_child", round_inst)
	# Free main menu
	owner.queue_free()
