extends Label

onready var match_label = $MatchNum
onready var match_slider = $HSlider

var match_nums = [1, 2, 3, 4, 5]
var match_index = 2

func move_direc(direction):
	match_index = wrapi(match_index + direction, 0, match_nums.size())
	match_label.text = str(match_nums[match_index])
	match_slider.value = match_nums[match_index]

func get_matchnum() -> int:
	return match_nums[match_index]
