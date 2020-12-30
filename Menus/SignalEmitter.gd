extends Label

signal selected

func select(_cursor):
	emit_signal("selected")
