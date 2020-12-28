extends KinematicBody2D

signal dead

# Player values
export(int) var player_num = 0

# DEFAULT
const PLAYER_GRAVITY = 9
const TURNOFF_SPEED = 15
const BASE_SPEED = 10 #25
var base_speed = BASE_SPEED
const ACCELERATION = 11
const MAX_SPEED = 130
var BOUNCE_FORCE = 300
var FALL_MULTIPLIER = 1.1
var JUMP_STRENGTH = 280
const SPAWN_MIN_DISTANCE = 30

# DIVE
var diving = false
var can_dive = true
const DIVE_SPEED = 192
const DIVE_FALL_MULTIPLIER = 0.85
const DIVE_OUT_STRENGTH = 200
const DIVE_OUT_SPEED = 140
const DIVE_MERCY = 3

# CLIMBING
var CLIMBING_SPEED = 200
var WALL_CLIMBING_SPEED = 150
var wall_climbing = false

# Sound effects
#onready var jump_sfx = get_node("SoundJump")
onready var scale_manager = get_node("ScaleChildren")
onready var animator = get_node("AnimationTree")
onready var core = get_node("ScaleChildren/PlayerCore")

onready var skidRayCast1 = get_node("SkidRay")
onready var skidRayCast2 = get_node("SkidRay2")

# Movement vars
var _stun := 0
var frozen := false
export(bool) var suspended := false
var ignore_air_friction := false
var direction_lock := false
var gravity := true

var max_velo = MAX_SPEED
var velo = Vector2()

var jump_timer = 0
const JUMP_TIME = 10
var slash_time = 0
const SLASH_TIME = 10
var coyoteTimer = 0
var climbing = false
var air_time = 0
var skid_perfect = false

# Initial spawn for players dying. An educated guess for a legal, safe position
var cur_spawn = Vector2()

export(float) var release_jump_damp = 0.4

var direction = 1

export var on_ladders = 0

func reset_position():
	position = cur_spawn
	velo = Vector2()

func set_spawn(pos):
	position = pos
	cur_spawn = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move(delta)
	manage_flags()

func move(delta):
	var horizontal = (Input.get_action_strength(Constants.CONTROLS[player_num]["right"]) - Input.get_action_strength(Constants.CONTROLS[player_num]["left"]))
	var vertical = (Input.get_action_strength(Constants.CONTROLS[player_num]["down"]) - Input.get_action_strength(Constants.CONTROLS[player_num]["up"]))
	
	if _stun > 0:
		horizontal = 0
		vertical = 0
		_stun -= 1
	
	if frozen or diving:
		horizontal = 0; vertical = 0
	
	# Setting direction
	if !direction_lock:
		if horizontal * direction < 0:
			if horizontal > 0:
				direction = 1
			else:
				direction = -1
		if scale_manager.scale.x != direction:
			scale_manager.scale = Vector2(direction, 1)
	
	# Friction
	if (horizontal == 0 and !ignore_air_friction and !is_on_floor()):
		velo.x *= 0.87
	elif (horizontal == 0 and is_on_floor()):
		velo.x *= 0.87
	elif (is_on_floor() and abs(velo.x) > max_velo):
		velo.x *= 0.87
	elif diving: # Diving friction
		if is_on_floor():
			velo.x *= 0.93
	
	# Basic movement
	velo.x = calc_direc(horizontal, velo.x, ACCELERATION)
	
	# Skid perfect
	if skid_perfect and is_on_floor():
		if !skidRayCast1.is_colliding() or !skidRayCast2.is_colliding():
			velo.x *= 0.86
	
	# Animating
	if horizontal != 0:
		animator["parameters/PlayerMovement/conditions/walking"] = true
		animator["parameters/PlayerMovement/conditions/not_walking"] = false
	else:
		animator["parameters/PlayerMovement/conditions/walking"] = false
		animator["parameters/PlayerMovement/conditions/not_walking"] = true
	
	#Gravity
	if gravity and !climbing:
		if velo.y < 0:
			velo.y += PLAYER_GRAVITY
		else:
			if diving:
				velo.y += PLAYER_GRAVITY * DIVE_FALL_MULTIPLIER
			else:
				velo.y += PLAYER_GRAVITY * FALL_MULTIPLIER
			# terminal velocity
			if velo.y > Constants.terminalVelocity:
				velo.y = Constants.terminalVelocity
	
	# Ladder climbing
	if vertical != 0 and on_ladders > 0:
		velo.y = vertical * CLIMBING_SPEED
		climbing = true
	elif climbing:
		if vertical == 0:
			velo.y = 0
		if on_ladders == 0:
			climbing = false
	
	# Apply Movement
	if !suspended:
		velo = move_player(velo)

func calc_direc(ui_direc, cur_speed, accel = ACCELERATION, speed = base_speed):
	if ui_direc > 0 and cur_speed >= ui_direc*base_speed*.9: # Accelerate right
		return max(cur_speed, min(cur_speed + ui_direc*accel, max_velo))
	elif ui_direc > 0 and cur_speed > -ui_direc*TURNOFF_SPEED: # On low speed, set to base speed instantly
		return max(cur_speed, ui_direc*speed)
	elif ui_direc < 0 and cur_speed <= ui_direc*base_speed*.9: # Accelerate left
		return min(cur_speed, max(cur_speed + ui_direc*accel, -max_velo))
	elif ui_direc < 0 and cur_speed < -ui_direc*base_speed: # On low speed, set to base speed instantly
		return min(cur_speed, ui_direc*speed)
	elif ui_direc != 0:  # Sliding for when velo is launched out of regular range (and attempting to turn back)
		return cur_speed + ui_direc*accel
	elif ui_direc == 0 and abs(cur_speed) <= TURNOFF_SPEED:  # Hard stop on release
		return 0
	else:
		return cur_speed

#onready var feetCollider = get_node("FeetCollider")
func move_player(v):
	#var snap = Vector2.DOWN * 16 if is_on_floor() and !just_jumped else Vector2.ZERO
	var prev_velo = v
	var new_velo = move_and_slide(v, Vector2.UP)#_with_snap(velo, snap, Vector2.UP, true)
	var recognize_collision = true
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision != null:
			if !collision.collider.is_in_group("player"):
				# Special cases when hitting level tiles
				if collision.collider.get_collision_layer_bit(1) == true:
					# Corner correction
					if collision.local_shape.get_name() == "HeadCollider":
						if collision.position.y > collision.local_shape.global_position.y - collision.local_shape.shape.radius + .15:
							# Push player vertically and set recognize_collision to false
							recognize_collision = false
							if collision.position.x < global_position.x:
								position.x += 1
							else:
								position.x -= 1
					# Hitting blocks
					#if recognize_collision:
					#	if collision.local_shape != feetCollider:
					#		if collision and collision.collider.is_in_group("block"):
					#			collision.collider.collide(collision, self)
	if !recognize_collision:
		new_velo = prev_velo
	#if bashing:
	#	new_velo.y = 0
	return new_velo

func push(direc):
	if ( velo.x * direc.x < 0 or abs(velo.x) < abs(direc.x) ):
		velo.x = direc.x
	if ( velo.y * direc.y < 0 or abs(velo.y) < abs(direc.y) ):
		velo.y = direc.y

func manage_flags():
	if is_on_floor() or climbing or suspended:
		refresh_flags()
	else:
		if !air_time:
			air_time = true
		if coyoteTimer > 0:
			coyoteTimer -= 1
	
	if (is_on_floor() or suspended) and air_time:
		air_time = false
		animator["parameters/PlayerMovement/conditions/jumping"] = false
		animator["parameters/PlayerMovement/conditions/not_jumping"] = true
	
	if is_on_floor() and ignore_air_friction:
		if !diving and abs(velo.x) < max_velo*.8:
			ignore_air_friction = false
	
	if diving and is_on_floor():
		animator["parameters/PlayerMovement/playback"].travel("idle")
	
	if slash_time > 0:
		slash_time -= 1
		if animator["parameters/PlayerMovement/playback"].get_current_node() != "slash" \
			and animator["parameters/PlayerMovement/playback"].get_current_node() != "slash2":
			animate("slash")
			animator["parameters/PlayerMovement/conditions/slash2"] = !animator["parameters/PlayerMovement/conditions/slash2"]
	
	if jump_timer > 0:
		jump_timer -= 1
		if _stun <= 0 \
			and (is_on_floor() \
				or coyoteTimer > 0 \
				or climbing \
				or diving):
			jump()

func refresh_flags():
	if coyoteTimer < 5:
		coyoteTimer = 5
	if !can_dive:
		can_dive = true

var holding_jump = false

func _unhandled_input(event):
	if !frozen:
		# This will run once on the frame when the action is first pressed
		if event.is_action_pressed(Constants.CONTROLS[player_num]["jump"]):
			holding_jump = true
			jump_timer = JUMP_TIME
		if event.is_action_released(Constants.CONTROLS[player_num]["jump"]):
			if holding_jump and !diving and velo.y < 0:
				velo.y *= release_jump_damp
				#animator["parameters/playback"].travel("freefall")
			holding_jump = false
			jump_timer = 0
		
		# This will run once on the frame when the action is first pressed
		if event.is_action_pressed(Constants.CONTROLS[player_num]["slash"]):
			slash_time = SLASH_TIME
		
		if event.is_action_pressed(Constants.CONTROLS[player_num]["dive"]):
			dive()

func jump():
	if !diving: # Basic Jump
		push(Vector2(0, -JUMP_STRENGTH))
	else: # Out-of-dive Jump
		undive()
		push(Vector2(0, -DIVE_OUT_STRENGTH))
	# Energy jump
	coyoteTimer = 0
	jump_timer = 0
	climbing = false
	#jump_sfx.play()
	animator["parameters/PlayerMovement/conditions/jumping"] = true
	animator["parameters/PlayerMovement/conditions/not_jumping"] = false

func bounce():
	var direc = Vector2(0, -BOUNCE_FORCE)
	if !holding_jump:
		direc *= release_jump_damp
	push(direc)
	refresh_flags()

func get_stun():
	return _stun

func release_all_powers():
	if diving:
		animator["parameters/PlayerMovement/playback"].start("end_dive")
		undive()

func stun(amo, stun_mult = 3):
	_stun = amo * stun_mult
	release_all_powers()

func set_freeze(flag):
	if flag == true:
		release_all_powers()
	frozen = flag

func suspend_movement(flag : bool):
	suspended = flag

# Universal method for other nodes to know if keys and actions from
# the player can be used. This is good for dialog, death scenes, etc
func is_active():
	return !suspended and !frozen

##############################
# STATE METHODS
####################

func dive():
	if can_dive and !diving:
		can_dive = false
		diving = true
		ignore_air_friction = true
		max_velo = DIVE_SPEED
		velo = Vector2(DIVE_SPEED * direction, -DIVE_SPEED*3/4)
		animator["parameters/PlayerMovement/playback"].travel("dive")
		animator["parameters/PlayerMovement/conditions/jumping"] = false
		animator["parameters/PlayerMovement/conditions/not_jumping"] = true
func undive():
	diving = false
	max_velo = MAX_SPEED
	if velo.x > 0:
		velo.x = min(DIVE_OUT_SPEED, velo.x)
	else:
		velo.x = max(-DIVE_OUT_SPEED, velo.x)

func start_skid_perfect():
	skid_perfect = true
func stop_skid_perfect():
	skid_perfect = false

##############################
# EXTERNAL NODE METHODS
####################

func reset():
	core.reset()

func respawn_player():
	core.respawn_player()

func respawn():
	var spawn_points = get_tree().get_nodes_in_group("spawn")
	var spawn_position = position
	var distance = 0
	while distance < SPAWN_MIN_DISTANCE:
		spawn_position = spawn_points[randi() % spawn_points.size()].position
		distance = INF
		for player in get_tree().get_nodes_in_group("player"):
			if spawn_position.distance_to(player.position) < distance:
				distance = spawn_position.distance_to(player.position)
	position = spawn_position

func get_direction():
	return direction

func lock_direction(flag : bool):
	direction_lock = flag

func set_velo(new_velo):
	velo = new_velo
func set_velo_x(x):
	velo.x = x
func set_velo_y(y):
	velo.y = y

func get_power_node():
	return $Power

func animate(animation):
	release_all_powers()
	animator["parameters/PlayerMovement/playback"].travel(animation)

func set_skin(skin_name):
	animator["parameters/Skin/playback"].travel(skin_name)

func damage(isStomp, amount = 1):
	core.damage(isStomp, amount)
func heal(amount = 1):
	core.heal(amount)

onready var menu_position = position
func move_to_menu_position():
	position = menu_position

onready var gravity_timer = get_node("GravityTimer")
func pause_gravity():
	gravity = false
	gravity_timer.start()
func resume_gravity():
	gravity = true
	gravity_timer.stop()
