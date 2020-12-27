extends Node2D

onready var camera = $Camera
onready var level_name_label = $LevelName
onready var tween = $Tween

var is_active := true
var level_node : Node = null
var level_index := 0
var level_names : Array
export(String) var levels_file = "res://levels/"
var choosing_player = 0
var player_won := -1

onready var wins = [$Player1Wins, $Player2Wins]
onready var glory_spotlights = [$Player1Glory, $Player2Glory]
onready var selecting_text = [$Player1Selecting, $Player2Selecting]

func init(num_matches : int, skins : Array):
	wins = [$Player1Wins, $Player2Wins]
	for win in wins:
		win.set_required_wins(num_matches)

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
		if event.is_action_pressed(Constants.CONTROLS[choosing_player]["left"]):
			level_index = wrapi(level_index + 1, 0, level_names.size())
			change_level = true
		if event.is_action_pressed(Constants.CONTROLS[choosing_player]["right"]):
			level_index = wrapi(level_index -1, 0, level_names.size())
			change_level = true
		if event.is_action_pressed(Constants.CONTROLS[choosing_player]["jump"]):
			# Scale level up
			tween.interpolate_property(level_node, "scale",
				Vector2(0.5, 0.5), Vector2(1, 1), 2,
				Tween.TRANS_BACK, Tween.EASE_IN_OUT)
			tween.start()
			# Hide players and gui
			get_tree().call_group("player", "animate", "hide")
			hide()
			camera.set_level(level_node)
		if change_level:
			set_level()
	if player_won >= 0:
		if event.is_action_pressed(Constants.CONTROLS[player_won]["jump"]):
			# Create Scene
			var round_inst = load("res://Menus/MainMenu.tscn").instance()
			get_tree().get_root().call_deferred("add_child", round_inst)
			# Free
			queue_free()

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
	for win_texture in wins:
		win_texture.visible = false
	is_active = false
	selecting_text[choosing_player].visible = false

func show():
	level_name_label.visible = true
	for win_texture in wins:
		win_texture.visible = true
	is_active = true
	selecting_text[choosing_player].visible = true

func _on_Player_dead(player_num : int):
	# Change wins num
	var winning_player = 1 - player_num
	choosing_player = player_num
	end_level(winning_player)

func end_level(winning_player):
	# Move players
	get_tree().call_group("player", "move_to_menu_position")
	get_tree().call_group("player", "animate", "idle")
	get_tree().call_group("player", "suspend_movement", true)
	get_tree().call_group("player", "reset")
	camera.set_level(null)
	# Increment win counter
	var round_won = wins[winning_player].increment()
	if round_won:
		show_stats(winning_player)
	else:
		reopen_select()

func reopen_select():
	# Clean up level
	call_deferred("set_level")
	# Restart level select
	show()

func show_stats(winning_player):
	if level_node:
		level_node.queue_free()
	glory_spotlights[winning_player].visible = true
	level_name_label.text = "Player " + str(winning_player+1) + " Wins!"
	level_name_label.visible = true
	player_won = winning_player