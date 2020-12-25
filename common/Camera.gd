extends Camera2D

var level : Node2D = null

export(NodePath) var player1 = "."
export(NodePath) var player2 = "."

onready var focal_point_1 = get_node(player1)
onready var focal_point_2 = get_node(player2)

func set_level(new_level : Node2D):
	level = new_level
	if level:
		limit_top = level.up
		limit_bottom = level.down
		limit_left = level.left
		limit_right = level.right

func _process(delta):
	global_position = (focal_point_1.global_position + focal_point_2.global_position)/2
