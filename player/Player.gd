extends Sprite

#onready var jump_enem_sfx = get_node("SoundJumpEnmy")
#onready var hurt_sfx = get_node("SoundHurt")

onready var controller = get_parent().get_parent()
onready var player_num = controller.player_num
onready var hurtbox = get_node("../hurtbox")
onready var animator = get_node("../../AnimationTree")

var MAX_HEALTH = 3
var health = 3

signal hurt

func _process(delta):
	if respawn:
		animator['parameters/PlayerMovement/playback'].travel('die')

func _unhandled_input(event):
	if Constants.DEBUG_MODE:
		if event is InputEventKey and event.pressed and event.scancode == KEY_BRACELEFT:
			damage(false)
		if event is InputEventKey and event.pressed and event.scancode == KEY_BRACERIGHT:
			heal()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("hitbox") and area.get_parent() != get_parent():
		var damage = area.get_damage()
		damage(false, damage)
	elif area.is_in_group("ladder"):
		controller.on_ladders += 1

# Bash at body. If the object is destroyed, return true
func attack(body):
	if body.has_method("damage"):
		# TODO: Play sound effect
		var destroyed = body.damage(false)
		return destroyed
	return false

func cliff_damage():
	health = 0
	Gui.update_health(player_num, health, MAX_HEALTH)
	respawn = true

var respawn = false
func damage(isStomp, damage = 1) -> bool:
	health -= damage
	Gui.update_health(player_num, health, MAX_HEALTH)
	respawn = true
	# Player disappears. Return true
	return true

func respawn_player():
	respawn = false
	# Generate effect
	var effect = preload("res://player/Respawneffect.tscn")
	var effect_object = effect.instance()
	effect_object.position = controller.position
	controller.get_parent().add_child(effect_object)
	# Move player
	controller.respawn()
	effect_object.set_target(controller.position)
	effect_object.set_callback_node(self)
	effect_object.start()

func respawn_complete():
	animator['parameters/PlayerMovement/playback'].travel('idle')

func heal(amo = 1):
	health = min(health + amo, MAX_HEALTH)
	Gui.update_health(player_num, health, MAX_HEALTH)

onready var uninvincible_timer = get_node("../../Uninvincible")
func turn_invincibilty(flag):
	if flag == true:
		uninvincible_timer.start()
		hurtbox.set_collision_layer_bit(0, false)
		hurtbox.set_collision_mask_bit(0, false)
	else:
		uninvincible_timer.stop()
		hurtbox.set_collision_layer_bit(0, true)
		hurtbox.set_collision_mask_bit(0, true)

func _on_hurtbox_area_exited(area):
	if area.is_in_group("ladder"):
		controller.on_ladders -= 1

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and body != controller:
			controller.bounce()
