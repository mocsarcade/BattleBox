extends Node2D

var cameraZoom = 2
var terminalVelocity = 400
var camera_radius = Vector2(160, 120)

var DEBUG_MODE = true

var CONTROLS = [
	{
		"up": "ui_up",
		"left": "ui_left",
		"right": "ui_right",
		"down": "ui_down",
		"jump": "ui_jump",
		"dive": "ui_dive",
		"slash": "ui_slash"
	},
	{
		"up": "ui2_up",
		"left": "ui2_left",
		"right": "ui2_right",
		"down": "ui2_down",
		"jump": "ui2_jump",
		"dive": "ui2_dive",
		"slash": "ui2_slash"
	}
]

enum SELECTION_TYPES {
	LOSERS_PICK,
	WINNERS_PICK,
	TURNS
}

func get_selection_type_name(selection_index):
	match selection_index:
		Constants.SELECTION_TYPES.LOSERS_PICK:
			return "Losers Pick"
		Constants.SELECTION_TYPES.WINNERS_PICK:
			return "Winners Pick"
		Constants.SELECTION_TYPES.TURNS:
			return "Turns"
