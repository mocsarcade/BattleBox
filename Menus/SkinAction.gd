extends Label

onready var player_visuals = [$Player, $Player2]

var skin_names = ["Basic", "Cowboy", "Purple", "Duck", "Gun"]
var skin_index = [0, 0]

func move_direc(player_num, direction):
	skin_index[player_num] = wrapi(skin_index[player_num] + direction, 0, skin_names.size())
	player_visuals[player_num].set_skin(skin_names[skin_index[player_num]])
	print(skin_names[skin_index[player_num]])

func get_skinnames() -> int:
	var ret = []
	for index in skin_index:
		ret.append(skin_names[index])
	return ret
