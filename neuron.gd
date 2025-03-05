extends Node2D

signal done

var threshold: float = 1.0
var _puzzle_completed = false  # Track if the puzzle has been solved

@onready var slider1: HSlider = $Slider1
@onready var slider2: HSlider = $Slider2
@onready var threshold_slider: HSlider = $ThresholdSlider
@onready var threshold_line: Line2D = $Neuron/ActivationFunction/Threshold
@onready var lamp: Sprite2D = $Lamp
@onready var activation_function: Path2D = $Neuron/ActivationFunction

func _ready() -> void:
	# Set up threshold slider range (max is 2.0 since both sliders can be 1.0)
	threshold_slider.max_value = 2.0
	threshold_slider.value = 1.0  # 50% of max
	update_threshold_line()

func _on_slider_changed(_value: float) -> void:
	threshold = threshold_slider.value
	var weighted_sum = calculate_weighted_sum()
	update_neuron_state(weighted_sum)
	update_graph_position(weighted_sum)
	update_threshold_line()

func calculate_weighted_sum() -> float:
	return (slider1.value) + (slider2.value)

func update_neuron_state(sum: float) -> void:
	if sum >= threshold:  # Will activate when sum is 1.0 or greater (50% or more of max 2.0)
		lamp.turn_on()
		
		# Emit the done signal if puzzle wasn't completed before
		if not _puzzle_completed:
			_puzzle_completed = true
			emit_signal("done")
	else:
		lamp.turn_off()

func update_graph_position(sum: float) -> void:
	var progress = clamp(sum / 2.0, 0.0, 1.0)  # Changed to divide by 2.0 instead of THRESHOLD
	var point_position = activation_function.curve.sample_baked(progress * activation_function.curve.get_baked_length())
	$Neuron/ActivationFunction/GraphPos.position = point_position

func update_threshold_line() -> void:
	var progress = clamp(threshold / 2.0, 0.0, 1.0)
	var point = activation_function.curve.sample_baked(progress * activation_function.curve.get_baked_length())
	threshold_line.position.y = point.y

# Reset function to allow replay of the puzzle
func reset_puzzle() -> void:
	_puzzle_completed = false
	slider1.value = 0
	slider2.value = 0
	threshold_slider.value = 1.0
	threshold = 1.0
	
	var weighted_sum = calculate_weighted_sum()
	update_neuron_state(weighted_sum)
	update_graph_position(weighted_sum)
	update_threshold_line()
