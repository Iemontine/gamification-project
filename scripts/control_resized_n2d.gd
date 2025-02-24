@tool

class_name ControLResizedNode2D
extends Node2D

var parent
@onready var size = $BoundingBox/CollisionShape2D.shape.size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	update_scale()


func update_scale() -> void:
	if parent is not Control: return
	var parent_size = parent.size

	var scale_factor = parent_size.x / size.x
	scale.x = scale_factor
	scale.y = scale_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	update_scale()
