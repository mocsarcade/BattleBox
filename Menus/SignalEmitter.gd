extends Label

signal selected

func select():
	emit_signal("selected")
