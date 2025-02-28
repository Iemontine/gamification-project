class_name Page
extends VBoxContainer

# Dictionary to track which sections are controlled by which buttons
var _continue_button_sections: Dictionary = {}
# Reference to the NextButton if it exists
@onready var _next_button: Button = $NextButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_sections_visibility()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# Setup the initial visibility of sections based on ContinueButtons
func _setup_sections_visibility() -> void:
	var children = get_children()
	
	var current_button = null
	var controlled_sections = []
	_next_button.visible = false
	
	for i in range(children.size()):
		var child = children[i]
		
		if child.name.begins_with("ContinueButton"):
			# If we had a previous button, store its controlled sections
			if current_button != null:
				_continue_button_sections[current_button] = controlled_sections
			
			# Start tracking sections for this button
			current_button = child
			controlled_sections = []
			
			# Connect button signal
			child.pressed.connect(_on_continue_button_pressed.bind(child))
		
		# If this is a section after a button, hide it initially
		elif child.name.begins_with("Section") and current_button != null:
			controlled_sections.append(child)
			child.visible = false
	
	# Store the last button's controlled sections
	if current_button != null and controlled_sections.size() > 0:
		_continue_button_sections[current_button] = controlled_sections
	
	# Update button visibility
	_update_button_visibility()
	
	# Check if we should show the NextButton immediately (if all sections are visible)
	_update_next_button_visibility()

# Update which ContinueButtons should be visible
func _update_button_visibility() -> void:
	var children = get_children()
	
	# First hide all buttons
	for child in children:
		if child.name.begins_with("ContinueButton"):
			child.visible = false
	
	# Find the first button that controls at least one invisible section
	for i in range(children.size()):
		var child = children[i]
		
		if child.name.begins_with("ContinueButton"):
			var sections = _continue_button_sections.get(child, [])
			var has_invisible_section = false
			
			for section in sections:
				if not section.visible:
					has_invisible_section = true
					break
			
			if has_invisible_section:
				child.visible = true
				break

# Check if all sections are visible to determine if NextButton should be shown
func _update_next_button_visibility() -> void:
	if _next_button == null:
		return
		
	var all_sections_visible = true
	
	# Check if all sections are visible
	for child in get_children():
		if child.name.begins_with("Section") and not child.visible:
			all_sections_visible = false
			break
	
	# Show NextButton only when all sections are visible
	_next_button.visible = all_sections_visible
	_next_button.disabled = false

# Handle button click events
func _on_continue_button_pressed(button: Button) -> void:
	# Make all sections controlled by this button visible
	var sections = _continue_button_sections.get(button, [])
	for section in sections:
		section.visible = true
	
	# Disable the button to prevent multiple clicks
	button.disabled = true
	
	# Update button visibility
	_update_button_visibility()
	
	# Check if we should show the NextButton
	_update_next_button_visibility()
	
	# Scroll to bottom if parent is a SmoothScrollContainer
	if get_parent() is SmoothScrollContainer:
		var parent = get_parent() as SmoothScrollContainer
		# Allow a small delay for layout updates
		await get_tree().physics_frame
		await get_tree().create_timer(0.001).timeout
		parent.scroll_to_bottom()
		print("Continue pressed")
