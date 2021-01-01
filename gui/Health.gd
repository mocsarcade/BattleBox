extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	animator['parameters/playback'].travel("flashy")

onready var animator = $AnimationTree
func animate_spawn():
	visible = true
	animator['parameters/playback'].travel("Generate")

func hide():
	visible = false
