extends Label

export(NodePath) var matchnum_node
export(NodePath) var skins_node

func select():
	# Create Scene
	var round_inst = load("res://Menus/RoundManager.tscn").instance()
	get_tree().get_root().add_child(round_inst)
	round_inst.call_deferred("init", get_node(matchnum_node).get_matchnum(), get_node(skins_node).get_skinnames())
	# Free main menu
	owner.queue_free()
