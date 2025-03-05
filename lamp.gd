extends Sprite2D

@onready var light: PointLight2D = $Light

@onready var lamp_on_texture: Texture = preload("res://lampon.png")
@onready var lamp_off_texture: Texture = preload("res://lampoff.png")

func _ready():
	set_on(false)

func set_on(is_on: bool):
	light.enabled = is_on
	# Change lamp appearance based on state
	modulate = Color(1, 1, 0.7, 1) if is_on else Color(0.5, 0.5, 0.5, 1)

func turn_on():
	set_on(true)

func turn_off():
	set_on(false)
