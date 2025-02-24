extends VBoxContainer

@onready var content_num = get_child_count()
@onready var content_pos = 1
@onready var content = get_children()
@onready var scroller:SmoothScrollContainer = $"../.."

const TYPING_SPEED = 0.05  # Adjust this value to change typing speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1, content_num - 1):
		content[i].visible = false
	content[0].visible = true
	content[content_num - 1].visible = true

func show_text_gradually(label: Label) -> void:
	var final_text = label.text
	label.visible_characters = 0
	label.text = final_text
	
	for i in final_text.length():
		label.visible_characters += 1
		await get_tree().create_timer(TYPING_SPEED).timeout

func _on_reveal_button_pressed() -> void:
	if content_pos < content_num - 1:
		content[content_pos].visible = true
		
		# Check if the container has a Label child
		for child in content[content_pos].find_children("Label", "", true):
			if child is Label:
				await show_text_gradually(child)
		
		content_pos += 1

	if content_pos >= content_num - 1:
		content[content_num - 1].visible = false

	await get_tree().create_timer(0.01).timeout
	scroller.scroll_to_bottom()
