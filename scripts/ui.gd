extends Control


# Page variables
var current_page = 0


@onready var container = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/VBoxContainer/AspectRatioContainer
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/CenterContainer/GridContainer/VBoxContainer/ProgessContainer/ProgressBar
#@onready var back_button: Button = $MarginContainer/CenterContainer/GridContainer/BackButton
#@onready var next_button: Button = $MarginContainer/CenterContainer/GridContainer/NextButton
@onready var pages = []
var total_steps = 0
var locked = []
var current_step = 0


func _ready():
	# Lock all pages on ready
	pages = container.find_children("Page*", "", true, false)
	total_steps = pages.size()
	locked.resize(total_steps)
	locked.fill(true)


func _input(event):
	if event.is_action_pressed("ui_down"):
		navigate(1)
	elif event.is_action_pressed("ui_up"):
		navigate(-1)


func _on_next_button_pressed():
	navigate(1)


func _on_back_button_pressed():
	navigate(-1)


func navigate(direction):
	var next_page = current_page

	if direction == 1:
		# Moving forward
		if current_page < pages.size() - 1: next_page += 1
		else: return
			
		# Check if the current step is locked
		if locked[current_step]: return
	else:
		# Moving backward always allowed
		if current_page > 0: next_page -= 1
		else: return
	
	current_step = next_page
	change_page_visibility(next_page)

func change_page_visibility(next_page: int):
	print("Moving to page ", next_page)

	# Page change - simply toggle visibility
	# TODO: Add fade in/out, anims
	pages[current_page].visible = false
	pages[next_page].visible = true
	
	# Update progress bar, current step
	progress_bar.value = (next_page / float(total_steps)) * 100
	current_page = next_page

func get_label(page: Control) -> Label:
	return page.find_children("Label", "Label", true)[0]

func unlock_current_step():
	print(current_step)
	locked[current_step] = false
