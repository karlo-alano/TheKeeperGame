extends Area3D

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
	if Globals.get_is_in_dialogue():
		return
	if GlobalTracker.current_day == 1 and GlobalTracker.run_once_per_day("lolo_day1_after_forsythe"):
		body.look_at(global_position)
		Globals.start_dialogue("Lolo_Day1_AfterForsythe", false)
