extends Area2D

onready var controller = $"../../"

func get_damage():
	if controller.is_active():
		return 1
	else:
		return 0
