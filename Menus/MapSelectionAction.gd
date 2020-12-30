extends Label

var selection_index = 0

func move_direc(player_num, direction):
	selection_index = wrapi(selection_index + direction, 0, Constants.SELECTION_TYPES.size())
	text = "Map Selection: " + Constants.get_selection_type_name(selection_index)

func get_selection_type() -> int:
	return selection_index

func select(cursor):
	cursor.move_cursor(1)
