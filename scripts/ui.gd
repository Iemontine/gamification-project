extends Control


const TYPING_SPEED = 0.05
const TRANSITION_TIME = 0.5


signal text_display_finished


# Page and section animation variables
var current_page = 0
var current_section = 0
var page_height = 600
var is_animating = false


@onready var container = $MarginContainer/CenterContainer/GridContainer/VBoxContainer/CenterContainer
@onready var progress_bar = $MarginContainer/CenterContainer/GridContainer/VBoxContainer/ProgressBar
@onready var back_button: Button = $MarginContainer/CenterContainer/GridContainer/BackButton
@onready var next_button: Button = $MarginContainer/CenterContainer/GridContainer/NextButton
@onready var pages = []
var sections_per_page = []
var total_steps = 0
var unlocked_steps = []
var current_step = 0


func _ready():
	# Find all the page nodes
	pages = container.find_children("Page*", "", true, false)
	
	# Find all the sections in each page
	for page in pages:
		var sections = page.find_children("Section*", "", true, false)
		sections_per_page.append(sections)
		total_steps += max(1, sections.size())
	
	# Initialize with first step unlocked
	unlocked_steps.resize(total_steps)
	unlocked_steps[0] = true


func _input(event):
	if is_animating:
		return
		
	if event.is_action_pressed("ui_down") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		navigate(1)
	elif event.is_action_pressed("ui_up") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP):
		navigate(-1)


func _on_next_button_pressed():
	navigate(1)


func _on_back_button_pressed():
	navigate(-1)


func navigate(direction):
	if is_animating: return

	var next_page = current_page
	var next_section = current_section
	var next_step = get_step_index(next_page, next_section)
	
	if direction > 0:
		# Moving forward
		if current_section < sections_per_page[current_page].size() - 1:
			next_section += 1
			next_step += 1
		elif current_page < pages.size() - 1:
			next_page += 1
			next_section = 0
			next_step += 1
		else:
			return
			
		# Check if next step is unlocked
		if not unlocked_steps[next_step]:
			return
	else:
		# Moving backward always allowed
		if current_section > 0:
			next_section -= 1
			next_step -= 1
		elif current_page > 0:
			next_page -= 1
			next_section = max(0, sections_per_page[next_page].size() - 1)
			next_step -= 1
		else:
			return
	
	current_step = next_step
	animate_transition(next_page, next_section)

func animate_transition(next_page: int, next_section: int):
	print(next_page, " ", next_section)

	# TODO: system where nodes that are identical between two sections/pages use an illusion to make it seem like they are the same node
	# This will allow for a more seamless transition between sections/pages
	# For example, if the next section has a node with the same name as the current section, the current node will fade out and the next node will fade in
	# This will make it seem like the node is the same, but with different content

	is_animating = true
	
	var tween = create_tween().set_parallel(true)
	
	if next_page != current_page:
		print("Page transition")
		# Page transition
		var current = pages[current_page]
		var next = pages[next_page]
		var direction = 1 if next_page > current_page else -1
		
		# Setup next page
		next.visible = true
		next.position.y = page_height * direction
		next.modulate = Color(1, 1, 1, 0)
		get_label(next).visible_characters = 0
		
		# Animate current page out
		tween.tween_property(current, "position:y", -page_height * direction, TRANSITION_TIME)
		tween.tween_property(current, "modulate", Color(1, 1, 1, 0), TRANSITION_TIME)
		
		# Animate next page in
		tween.tween_property(next, "position:y", 0, TRANSITION_TIME)
		tween.tween_property(next, "modulate", Color(1, 1, 1, 1), TRANSITION_TIME)

		# Set visibility after fade out, and show text based on unlock status
		tween.tween_callback(func(): 
			current.visible = false
			display_text(next)
		).set_delay(TRANSITION_TIME)
	else:
		print("Section transition")
		# Section transition
		var current = sections_per_page[current_page][current_section]
		var next = sections_per_page[next_page][next_section]
		
		# Setup sections
		current.visible = true
		next.visible = true
		next.modulate = Color(1, 1, 1, 0)
		get_label(next).visible_characters = 0
		next.position.y = 0  # Ensure position is reset
		
		# Fade out current section
		tween.tween_property(current, "modulate", Color(1, 1, 1, 0), TRANSITION_TIME)

		# Wait 1 second between Fade in next section
		tween.chain().tween_property(next, "modulate", Color(1, 1, 1, 1), TRANSITION_TIME)
		
		# Set visibility after fade out, and show text based on unlock status
		tween.tween_callback(func(): 
			current.visible = false
			display_text(next)
		).set_delay(TRANSITION_TIME)
	
	# Update progress bar
	var current_progress = 0
	for i in range(next_page):
		current_progress += max(1, sections_per_page[i].size())
	current_progress += next_section
	tween.tween_property(progress_bar, "value", (current_progress / float(total_steps)) * 100, TRANSITION_TIME)
	
	tween.finished.connect(func():
		current_page = next_page
		current_section = next_section
		is_animating = false
	)

func get_label(page_or_section: Control) -> Label:
	return page_or_section.find_children("Label", "Label", true)[0]

func display_text(control: Control):
	var label = get_label(control)
	if unlocked_steps[current_step]:
		# If step is unlocked, show text immediately
		label.visible_characters = -1
		text_display_finished.emit()
	else:
		# If step is locked, show text gradually
		show_text_gradually(label)

func show_text_gradually(label: Label) -> void:
	var final_text = label.text
	label.visible_characters = 0
	label.text = final_text
	
	for i in final_text.length():
		label.visible_characters += 1
		await get_tree().create_timer(TYPING_SPEED).timeout
	
	text_display_finished.emit()

func unlock_current_step():
	unlocked_steps[current_step] = true
	# Unlock next step if it exists
	if current_step + 1 < total_steps:
		unlocked_steps[current_step + 1] = true
		print("Unlocked step ", current_step)

func get_step_index(page: int, section: int) -> int:
	var step = 0
	for i in range(page):
		step += max(1, sections_per_page[i].size())
	return step + section

func is_current_step_locked() -> bool:
	return not unlocked_steps[current_step]
