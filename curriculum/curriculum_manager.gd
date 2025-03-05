class_name CurriculumManager
extends Node

signal lesson_completed(lesson_id: String)
signal course_completed(course_id: String)

# Dictionary of courses with their lessons
var curriculum = {
	"neural_networks_intro": {
		"title": "Introduction to Neural Networks",
		"lessons": [
			{
				"id": "brain_to_ai",
				"title": "From Brain Cells to AI",
				"scene": "res://pages/brain_to_ai.tscn",
				"completed": false
			},
			{
				"id": "neuron_basics",
				"title": "Neuron Fundamentals",
				"scene": "res://pages/neuron_basics.tscn", 
				"completed": false
			},
			{
				"id": "neural_networks",
				"title": "Simple Neural Networks",
				"scene": "res://pages/neural_network_basics.tscn",
				"completed": false
			}
		],
		"completed": false
	},
	"deep_learning": {
		"title": "Deep Learning Fundamentals",
		"lessons": [
			{
				"id": "deep_networks",
				"title": "Deep Neural Networks",
				"scene": "res://pages/deep_networks.tscn",
				"completed": false
			},
			{
				"id": "training",
				"title": "Training Neural Networks",
				"scene": "res://pages/training.tscn",
				"completed": false
			}
		],
		"completed": false
	}
}

# Current course and lesson tracking
var current_course_id = "neural_networks_intro"
var current_lesson_index = 0

func get_current_lesson():
	return curriculum[current_course_id]["lessons"][current_lesson_index]

func get_current_lesson_scene():
	return curriculum[current_course_id]["lessons"][current_lesson_index]["scene"]

func complete_current_lesson():
	var lesson = get_current_lesson()
	lesson["completed"] = true
	emit_signal("lesson_completed", lesson["id"])
	
	# Check if all lessons in course are completed
	var all_completed = true
	for l in curriculum[current_course_id]["lessons"]:
		if not l["completed"]:
			all_completed = false
			break
	
	if all_completed:
		curriculum[current_course_id]["completed"] = true
		emit_signal("course_completed", current_course_id)
	
	# Move to next lesson if available
	if current_lesson_index < curriculum[current_course_id]["lessons"].size() - 1:
		current_lesson_index += 1
		return true
	else:
		# Try to move to next course
		var course_ids = curriculum.keys()
		var current_index = course_ids.find(current_course_id)
		if current_index < course_ids.size() - 1:
			current_course_id = course_ids[current_index + 1]
			current_lesson_index = 0
			return true
	
	return false # No more lessons/courses

func get_progress():
	# Calculate overall progress
	var total_lessons = 0
	var completed_lessons = 0
	
	for course_id in curriculum.keys():
		var course = curriculum[course_id]
		for lesson in course["lessons"]:
			total_lessons += 1
			if lesson["completed"]:
				completed_lessons += 1
	
	if total_lessons == 0:
		return 0.0
	
	return float(completed_lessons) / float(total_lessons)
