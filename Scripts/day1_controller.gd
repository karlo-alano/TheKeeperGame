extends Node3D
class_name Day1Controller


func run_day1_intro() -> void:
	if GlobalTracker.run_once_per_day("world_day_1a_intro"):
		await get_tree().create_timer(3.0).timeout
		if is_inside_tree():
			# Play the Day 1 wake-up monologue after the prayer
			Globals.start_dialogue("MonologueD1A", true)


func setup_day1_world_b() -> void:
	Items.items["environment"].dayPosition()
	await get_tree().create_timer(2.0).timeout
