extends Area3D

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
	if GlobalTracker.eggTaskCompleted:
		body.look_at(global_position)
		Globals.start_dialogue("Lolo_Day1_B", false)
	else:
		return
