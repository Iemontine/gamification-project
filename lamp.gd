extends Sprite2D

@onready var light: PointLight2D = $Light

@onready var lamp_on_texture: Texture = preload("res://lampon.png")
@onready var lamp_off_texture: Texture = preload("res://lampoff.png")

func turn_on():
	light.energy = 1
	texture = lamp_on_texture

func turn_off():
	light.energy = 0
	texture = lamp_off_texture
