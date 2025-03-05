class_name Page
extends VBoxContainer

# Reference to the NextButton if it exists
@onready var _next_button: Button = $NextButton if has_node("NextButton") else null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_sections_visibility()
	_connect_neuron_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# Setup the initial visibility of sections based on the structure
func _setup_sections_visibility() -> void:
	var sections = _get_all_sections()
	if sections.is_empty():
		return
		
	# Hide NextButton initially
	if _next_button != null:
		_next_button.visible = false
	
	# Apply the Page's custom minimum size to all sections
	_apply_minimum_size_to_sections(sections)
	
	# Keep only the first section visible, hide all others
	var first_section = sections[0]
	first_section.visible = true
	
	# Make sure the ContinueButton in the first section is visible
	var first_button = _find_continue_button(first_section)
	if first_button != null:
		first_button.pressed.connect(_on_continue_button_pressed.bind(first_button))
		# Initially hide the button if we have a neuron simulator
		if _has_neuron_simulator(first_section):
			first_button.visible = false
		else:
			first_button.visible = true
	
	# Hide all other sections
	for i in range(1, sections.size()):
		sections[i].visible = false
		
		# Set up continue button signals for all sections
		var button = _find_continue_button(sections[i])
		if button != null:
			button.pressed.connect(_on_continue_button_pressed.bind(button))
	
	# Show NextButton if there are no sections with continue buttons
	_check_and_show_next_button()

# Connect signals from neuron simulators if they exist
func _connect_neuron_signals() -> void:
	var sections = _get_all_sections()
	for section in sections:
		var neuron_simulator = _find_neuron_simulator(section)
		if neuron_simulator:
			var continue_button = _find_continue_button(section)
			if continue_button:
				# Connect the neuron's done signal to show the continue button
				neuron_simulator.done.connect(_on_neuron_simulator_done.bind(continue_button))

# Check if section contains a neuron simulator
func _has_neuron_simulator(section: Node) -> bool:
	return _find_neuron_simulator(section) != null

# Find neuron simulator in a section if it exists
func _find_neuron_simulator(section: Node) -> Node2D:
	for element in section.get_children():
		if element is MarginContainer:
			for child in element.get_children():
				if child.get_class() == "Node2D" and child.name == "NeuronSlider":
					return child
	return null

# Callback when neuron simulator emits done signal
func _on_neuron_simulator_done(continue_button: Button) -> void:
	# Show the continue button when the neuron puzzle is solved
	continue_button.visible = true

# Apply the page's custom minimum size to all sections
func _apply_minimum_size_to_sections(sections: Array) -> void:
	# Get this page's custom minimum size
	var page_min_size = custom_minimum_size
	
	# Apply it to each section
	for section in sections:
		if section is Control:
			section.custom_minimum_size.x = page_min_size.x
			
			# Optional: if you want to preserve each section's own height
			# while only inheriting the width from the page
			if page_min_size.y > 0:
				section.custom_minimum_size.y = page_min_size.y

# Find all section nodes that are direct children of this Page
func _get_all_sections() -> Array:
	var sections = []
	for child in get_children():
		if child.name.begins_with("Section"):
			sections.append(child)
	return sections

# Find continue button in a section if it exists
func _find_continue_button(section: Node) -> Button:
	for child in section.get_children():
		if child is Button and child.name.begins_with("ContinueButton"):
			return child
	return null

# Get the index of a section in the page's children
func _get_section_index(section: Node) -> int:
	var sections = _get_all_sections()
	return sections.find(section)

# Handle continue button click events
func _on_continue_button_pressed(button: Button) -> void:
	# Find the section containing this button
	var parent_section = button.get_parent()
	if not parent_section.name.begins_with("Section"):
		push_error("Continue button's parent is not a Section")
		return
	
	# Find the next section
	var current_index = _get_section_index(parent_section)
	var sections = _get_all_sections()
	
	if current_index >= 0 and current_index < sections.size() - 1:
		# Make the next section visible
		var next_section = sections[current_index + 1]
		next_section.visible = true
		
		# Make the continue button of the next section visible
		var next_button = _find_continue_button(next_section)
		if next_button != null:
			# Only show the button if there's no neuron simulator
			if not _has_neuron_simulator(next_section):
				next_button.visible = true
	
	# Hide the clicked button
	button.visible = false
	
	# Check if we should show the NextButton
	_check_and_show_next_button()
	
	# Scroll to bottom if parent is a SmoothScrollContainer
	if get_parent() is SmoothScrollContainer:
		var parent = get_parent() as SmoothScrollContainer
		# Allow a small delay for layout updates
		await get_tree().physics_frame
		await get_tree().create_timer(0.001).timeout
		parent.scroll_to_bottom()

# Check if all sections are visible and the last section's button is invisible
func _check_and_show_next_button() -> void:
	if _next_button == null:
		return
		
	var sections = _get_all_sections()
	if sections.is_empty():
		_next_button.visible = true
		return
		
	var last_section = sections[sections.size() - 1]
	var last_button = _find_continue_button(last_section)
	
	# Show NextButton if:
	# 1. The last section is visible AND
	# 2. Either the last section has no continue button OR its continue button is invisible
	if last_section.visible and (last_button == null or not last_button.visible):
		_next_button.visible = true
	else:
		_next_button.visible = false
