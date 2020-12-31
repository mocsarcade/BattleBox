extends Camera2D

export(NodePath) var player1 = "."
export(NodePath) var player2 = "."

onready var focal_point_1 = get_node(player1)
onready var focal_point_2 = get_node(player2)
var active = false
var limits_l = -1000; var limits_r = 1000
var limits_t = -1000; var limits_b = 1000

func set_level(new_level : Node2D):
	if new_level:
		limits_t = new_level.up
		limits_b = new_level.down
		limits_l = new_level.left
		limits_r = new_level.right
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		smoothing_enabled = true
	else:
		limits_t = -1000
		limits_b = 1000
		limits_l = -1000
		limits_r = 1000
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false
		position = Vector2.ZERO
		smoothing_enabled = false

onready var base_zoom = self.zoom
onready var zoom_goal = base_zoom

func _process(delta):
	global_position = (focal_point_1.global_position + focal_point_2.global_position)/2
	# If we are in a level
	if smoothing_enabled:
		var distance = focal_point_1.global_position.distance_to(focal_point_2.global_position)
		var zoom_factor = distance * 0.0018
		zoom_goal = Vector2.ONE * clamp(zoom_factor, 0.5, .70)
		zoom = lerp(zoom, zoom_goal, 0.02)
		limit_bottom = limits_b; limit_top = limits_t * (zoom.y/base_zoom.y)
		limit_left = limits_l * (zoom.x/base_zoom.x); limit_right = limits_r * (zoom.x/base_zoom.x)
	else:
		zoom = base_zoom
