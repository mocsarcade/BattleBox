extends Camera2D

export(NodePath) var player1 = "."
export(NodePath) var player2 = "."

onready var focal_point_1 = get_node(player1)
onready var focal_point_2 = get_node(player2)

func set_level(new_level : Node2D):
	if new_level:
		limit_top = new_level.up
		limit_bottom = new_level.down
		limit_left = new_level.left
		limit_right = new_level.right
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
	else:
		limit_top = -1000
		limit_bottom = 1000
		limit_left = -1000
		limit_right = 1000
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false

func _process(delta):
	global_position = (focal_point_1.global_position + focal_point_2.global_position)/2
