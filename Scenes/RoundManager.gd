extends Node2D

onready var camera = $Camera
onready var level_name_label = $LevelName
onready var tween = $Tween

var is_active := true
var level_node : Node = null
var level_index := 0
var level_names : Array
export(String) var levels_file = "res://levels/"

func _ready():
	level_names = []
	var dir = Directory.new()
	if dir.open(levels_file) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				#var cookie_inst = load(levels_file + file_name).instance()
				level_names.append(file_name)
			file_name = dir.get_next()
	# Instantiate first scene
	call_deferred("set_level")

func _unhandled_input(event):
	# This will run once on the frame when the action is first pressed
	if is_active:
		var change_level = false
		if event.is_action_pressed("ui_left"):
			level_index = wrapi(level_index + 1, 0, level_names.size())
			change_level = true
		if event.is_action_pressed("ui_right"):
			level_index = wrapi(level_index -1, 0, level_names.size())
			change_level = true
		if event.is_action_pressed("ui_jump"):
			# Scale level up
			tween.interpolate_property(level_node, "scale",
				Vector2(0.5, 0.5), Vector2(1, 1), 2,
				Tween.TRANS_BACK, Tween.EASE_IN_OUT)
			tween.start()
			# Level name
			hide()
			camera.set_level(level_node)
		if change_level:
			set_level()

func spawn_players_in():
	# Spawn player
	get_tree().call_group("player", "animate", "die")

func set_level():
	if level_node:
		level_node.queue_free()
	level_node = load(levels_file + level_names[level_index]).instance()
	get_tree().get_root().add_child(level_node)
	level_node.scale = Vector2(.5, .5)
	level_name_label.text = level_names[level_index]

func hide():
	level_name_label.visible = false
	is_active = false

func show():
	level_name_label.visible = true
	is_active = true

func _on_Player_dead(player_num : int):
	# Clean up level
	call_deferred("set_level")
	camera.set_level(null)
	Gui.reset_energy()
	# Move players
	get_tree().call_group("player", "move_to_menu_position")
	get_tree().call_group("player", "animate", "idle")
	get_tree().call_group("player", "suspend_movement", true)
	get_tree().call_group("player", "reset")
	# Restart level select
	show()
