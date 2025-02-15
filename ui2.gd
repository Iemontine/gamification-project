extends Control

var current_page = 0
var total_pages = 3
var page_height = 600
var is_animating = false

@onready var pages = [
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/Page1,
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/Page2,
	$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/Page3
]
@onready var progress_bar = $MarginContainer/CenterContainer/VBoxContainer/ProgressBar

func _ready():
	update_pages()
	
func _unhandled_input(event):
	if is_animating:
		return
		
	if event.is_action_pressed("ui_down") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		navigate_pages(1)
	elif event.is_action_pressed("ui_up") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP):
		navigate_pages(-1)

func navigate_pages(direction):
	var next_page = current_page + direction
	if next_page < 0 or next_page >= total_pages:
		return
		
	is_animating = true
	
	var current = pages[current_page]
	var next = pages[next_page]
	
	# Set up initial positions
	current.visible = true
	next.visible = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Current page animation
	tween.set_trans(Tween.TransitionType.TRANS_QUAD)
	tween.tween_property(current, "position:y", -page_height * direction, 0.5).set_ease(Tween.EaseType.EASE_IN)
	tween.tween_property(current, "modulate", Color(1, 1, 1, 0), 0.5).set_ease(Tween.EaseType.EASE_IN)	
	
	# Next page animation
	next.position.y = page_height * direction
	next.modulate = Color(1, 1, 1, 0)
	tween.tween_property(next, "position:y", 0, 0.5).from(page_height * direction).set_ease(Tween.EaseType.EASE_IN)	
	tween.tween_property(next, "modulate", Color(1, 1, 1, 1), 0.5).set_ease(Tween.EaseType.EASE_IN)
	
	# Progress bar animation
	var next_progress = ((next_page + 1) / float(total_pages)) * 100
	tween.set_trans(Tween.TransitionType.TRANS_BOUNCE)
	tween.tween_property(progress_bar, "value", next_progress, 0.7)
	
	tween.finished.connect(func():
		is_animating = false
		current_page = next_page
		update_pages()
	)

func update_pages():
	for i in range(total_pages):
		pages[i].visible = (i == current_page)
		pages[i].position.y = 0
		pages[i].modulate = Color(1, 1, 1, 1)
