extends Label

export(NodePath) var matchnum_node
export(NodePath) var skins_node
export(NodePath) var selection_node

func select(_cursor):
	# Create Scene
	var round_inst = load("res://Menus/RoundManager.tscn").instance()
	get_tree().get_root().add_child(round_inst)
	round_inst.call_deferred("init", \
		get_node(matchnum_node).get_matchnum(), \
		get_node(skins_node).get_skinnames(), \
		get_node(selection_node).get_selection_type())
	# Free main menu
	owner.queue_free()
