tool
extends Node2D

export(int) var left = 32
export(int) var right = 32
export(int) var up = 32
export(int) var down = 32
export(Color, RGB) var col
export(int) var stageNum = 1

var prev_left = 0
var prev_right = 0
var prev_up = 0
var prev_down = 0

# Potentially use tilemap's get_used_rect instead for getting map size!
#var map_limits = $TileMap.get_used_rect()
#var map_cellsize = $TileMap.cell_size
#$Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
#$Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
#$Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
#$Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

var time_passed := 0.0
func _process(delta):
	if prev_left != left or prev_right != right \
		or prev_up != up or prev_down != down:
		update()
		prev_left = left
		prev_right = right
		prev_up = up
		prev_down = down

func _unhandled_input(event):
	if Constants.DEBUG_MODE:
		if event is InputEventKey and event.pressed and event.scancode == KEY_BACKSPACE:
			get_tree().reload_current_scene()

# Called when the node enters the scene tree for the first time.
func _draw():
	if not Engine.editor_hint:
		return
	
	draw_line(Vector2(left, up-160), Vector2(left, down+160), Color(1, 0, 0), 5)
	draw_line(Vector2(right, up-160), Vector2(right, down+160), Color(1, 0, 0), 5)
	draw_line(Vector2(left-160, up), Vector2(right+160, up), Color(1, 0, 0), 5)
	draw_line(Vector2(left-160, down), Vector2(right+160, down), Color(1, 0, 0), 5)
