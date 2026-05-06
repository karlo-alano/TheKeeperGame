extends Area3D

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
	# Prevent starting a dialogue if one is already running
	if Globals.get_is_in_dialogue():
		return
	if GlobalTracker.current_day == 1 and GlobalTracker.eggTaskCompleted and !GlobalTracker.dialogDone and GlobalTracker.run_once_per_day("lolo_day1_b"):
		body.look_at(global_position)
		Globals.start_dialogue("Lolo_Day1_B", false)
		GlobalTracker.dialogDone = true
	else:
		return
