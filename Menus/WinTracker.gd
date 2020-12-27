extends TextureProgress

export(int) var required_wins = 3
var cur_wins = 0

# Returns bool based on if the round has been successfully won
func increment():
	cur_wins += 1
	value = cur_wins
	if cur_wins >= required_wins:
		return true
	return false

func set_required_wins(num_wins):
	required_wins = num_wins
	max_value = num_wins
	$AnimationPlayer.play("Matches" + str(num_wins))
