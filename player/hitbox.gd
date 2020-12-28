extends Area2D

export(bool) var is_stomp = true
onready var controller = $"../../"

func get_damage():
	if controller.is_active():
		return 1
	else:
		return 0

func get_is_stomp():
	return is_stomp
