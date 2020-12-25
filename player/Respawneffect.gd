extends CPUParticles2D

var target : Vector2 = Vector2.ZERO
var respawn_callback_node = null
var velo : int = 50

func start():
	emitting = true	

func set_callback_node(callback):
	respawn_callback_node = callback

func set_target(target_pos: Vector2):
	target = target_pos
	velo = target.distance_to(position)

func _process(delta):
	if target:
		position = position.move_toward(target, delta*velo)
		if position.distance_to(target) <= delta*velo:
			if respawn_callback_node:
				respawn_callback_node.call_deferred("respawn_complete")
				queue_free()
