# Cursor iterates over every element in the current container
# (except for the last one, which is reserved for itself)

extends TextureRect

var selected_label = null
export(bool) var is_active = true

func set_active(flag):
	is_active = flag
	visible = flag

# Called when the node enters the scene tree for the first time.
func _ready():
	move_cursor(0)

func move_cursor(direction):
	if selected_label == null:
		selected_label = get_parent().get_child(0)
	else:
		var index = wrapi(selected_label.get_index()+direction, 0, get_parent().get_child_count()-1)
		selected_label = get_parent().get_child(index)
	rect_position.y = selected_label.rect_position.y

func _input(event):
	if is_active:
		if Input.is_action_just_pressed("ui_down"):
			move_cursor(1)
		elif Input.is_action_just_pressed("ui_up"):
			move_cursor(-1)
		if Input.is_action_just_pressed("ui_left"):
			if selected_label.has_method("move_direc"):
				selected_label.move_direc(-1)
		elif Input.is_action_just_pressed("ui_right"):
			if selected_label.has_method("move_direc"):
				selected_label.move_direc(1)
		elif Input.is_action_just_pressed("ui_jump"):
			if selected_label.has_method("select"):
				selected_label.select()
