extends Node3D

func _ready() -> void:
	if GlobalTracker.run_once_per_day("world_day_3a_intro"):
		await get_tree().create_timer(3.0).timeout
		if is_inside_tree():
			Globals.start_dialogue("Monologue3A", true)
