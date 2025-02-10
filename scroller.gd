extends VBoxContainer

@onready var content_num = get_child_count()
@onready var content_pos = 1
@onready var content = get_children()
@onready var scroller:SmoothScrollContainer = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1, content_num - 1):
		content[i].visible = false
	content[0].visible = true
	content[content_num - 1].visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reveal_button_pressed() -> void:
	if content_pos < content_num - 1:
		content[content_pos].visible = true
		content_pos += 1

	if content_pos >= content_num - 1:
		content[content_num - 1].visible = false

	await get_tree().create_timer(0.01).timeout
	scroller.scroll_to_bottom()
