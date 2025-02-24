@tool

extends ControLResizedNode2D

@export var input_neurons: int = 3
@export var hidden_layers: Array[int] = [4]  # Each element represents neurons in a hidden layer
var neuron_scene = preload("res://neuron.tscn")
var layer_spacing: float = 200.0  # Horizontal spacing between layers
var neuron_spacing: float = 100.0  # Vertical spacing between neurons

func _ready() -> void:
	initialize_network()
	super()

func initialize_network() -> void:
	var window_height = get_viewport_rect().size.y
	var total_layers = hidden_layers.size() + 2  # Input + hidden + output
	
	# Create input layer
	create_layer(0, input_neurons, window_height)
	
	# Create hidden layers
	for i in range(hidden_layers.size()):
		create_layer(i + 1, hidden_layers[i], window_height)
	
	# Create output layer (single neuron)
	create_layer(total_layers - 1, 1, window_height)

func create_layer(layer_index: int, num_neurons: int, window_height: float) -> void:
	var layer_x = layer_spacing * (layer_index + 1)
	var total_height = (num_neurons - 1) * neuron_spacing
	var start_y = (window_height - total_height) / 2
	
	for i in range(num_neurons):
		var neuron = neuron_scene.instantiate()
		add_child(neuron)
		neuron.position = Vector2(layer_x, start_y + i * neuron_spacing)
