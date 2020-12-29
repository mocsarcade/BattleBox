extends Node2D

onready var camera = $Camera
onready var level_name_label = $LevelName
onready var tween = $Tween

var NUM_PLAYERS = 2

var is_active := true
var level_node : Node = null
var level_index := 0
var level_names : Array
export(String) var levels_file = "res://levels/"
var choosing_player = 0
var selection_type = 0
var player_won := -1

onready var wins = [$Player1Wins, $Player2Wins]
onready var glory_spotlights = [$Player1Glory, $Player2Glory]
onready var selecting_text = [$Player1Selecting, $Player2Selecting]

func init(num_matches : int, skins : Array, selection_type_index : int):
	wins = [$Player1Wins, $Player2Wins]
	for win in wins:
		win.set_required_wins(num_matches)
	# Set player skins
	var players = [$Player, $Player2]
	for index in players.size():
		players[index].set_skin(skins[index])
	# Selection type
	selection_type = selection_type_index
	print(selection_type)

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
			scale_level(true)
			# Hide players and gui
			get_tree().call_group("player", "animate", "hide")
			hide()
			camera.set_level(level_node)
		if change_level:
			set_level()
	if player_won >= 0:
		if event.is_action_pressed(Constants.CONTROLS[player_won]["jump"]):
			goto_main()
	elif event.is_action_pressed("ui_cancel"):
		goto_main()

func goto_main():
	if level_node:
		level_node.queue_free()
	# Create Scene
	var round_inst = load("res://Menus/MainMenu.tscn").instance()
	get_tree().get_root().call_deferred("add_child", round_inst)
	# Free
	queue_free()

func spawn_players_in():
	# Spawn player
	get_tree().call_group("player", "animate", "die")

func scale_level(zoom_inwards : bool):
	# Decide start and end
	var start = Vector2.ONE; var end = Vector2(0.5, 0.5)
	if zoom_inwards:
		start = Vector2(0.5, 0.5); end = Vector2.ONE
	# Begin zoom
	tween.stop_all()
	tween.interpolate_property(level_node, "scale",
		start, end, 2,
		Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()
	# Connect or disconnect tween
	if zoom_inwards:
		tween.connect("tween_all_completed", self, "spawn_players_in")
	else:
		tween.disconnect("tween_all_completed", self, "spawn_players_in")

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
	match selection_type:
		Constants.SELECTION_TYPES.LOSERS_PICK:
			choosing_player = player_num
		Constants.SELECTION_TYPES.WINNERS_PICK:
			choosing_player = winning_player
		Constants.SELECTION_TYPES.TURNS:
			print(choosing_player, "-", NUM_PLAYERS)
			choosing_player = wrapi(choosing_player + 1, 0, NUM_PLAYERS)
			print(choosing_player)
	yield(get_tree().create_timer(4), "timeout")
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
	# Scale level down
	level_node.scale = Vector2(.5, .5)
	#scale_level(false)
	# Restart level select
	show()

func show_stats(winning_player):
	if level_node:
		level_node.queue_free()
	glory_spotlights[winning_player].visible = true
	level_name_label.text = "Player " + str(winning_player+1) + " Wins!"
	level_name_label.visible = true
	player_won = winning_player
