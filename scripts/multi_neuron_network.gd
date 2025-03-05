extends Node2D

signal done

var _puzzle_completed = false

# Node references
@onready var neuron1_slider = $Layer1/Neuron1/Slider
@onready var neuron1_value = $Layer1/Neuron1/Value
@onready var neuron2_slider = $Layer1/Neuron2/Slider
@onready var neuron2_value = $Layer1/Neuron2/Value
@onready var neuron3_value = $Layer2/Neuron3/Value
@onready var threshold_slider = $Controls/ThresholdSlider
@onready var threshold_value = $Controls/ThresholdValue
@onready var lamp = $Layer3/Lamp

# Weights between neurons (these could be adjustable too)
var weight_n1_to_n3 = 0.7
var weight_n2_to_n3 = 0.3

func _ready():
	# Initialize UI elements
	_update_network()
	
	# Set the weights on the connection visuals
	$Connections/N1toN3.weight = weight_n1_to_n3
	$Connections/N2toN3.weight = weight_n2_to_n3
	
	# Update weight labels
	$Connections/N1toN3/Weight.text = str(weight_n1_to_n3)
	$Connections/N2toN3/Weight.text = str(weight_n2_to_n3)

func _update_network():
	# Get input values
	var input1 = neuron1_slider.value
	var input2 = neuron2_slider.value
	var threshold = threshold_slider.value
	
	# Update display values
	neuron1_value.text = "%.1f" % input1
	neuron2_value.text = "%.1f" % input2
	threshold_value.text = "%.2f" % threshold
	
	# Calculate neuron 3's weighted sum
	var weighted_sum = input1 * weight_n1_to_n3 + input2 * weight_n2_to_n3
	neuron3_value.text = "%.2f" % weighted_sum
	
	# Update lamp state based on threshold
	var activated = weighted_sum >= threshold
	lamp.set_on(activated)
	
	# Emit done signal if lamp activates and puzzle wasn't completed before
	if activated and not _puzzle_completed:
		_puzzle_completed = true
		emit_signal("done")

func _on_input_changed(_value):
	# Called when either input neuron's slider value changes
	_update_network()

func _on_threshold_changed(_value):
	# Called when the threshold slider value changes
	_update_network()

func _on_reset_button_pressed():
	# Reset all network values to initial state
	neuron1_slider.value = 0
	neuron2_slider.value = 0
	threshold_slider.value = 0.5
	_puzzle_completed = false
	_update_network()