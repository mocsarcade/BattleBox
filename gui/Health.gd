extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("flashy")

onready var animator = $AnimationTree
func animate_spawn():
	visible = true
	animator['parameters/playback'].travel("Generate")

func hide():
	visible = false
