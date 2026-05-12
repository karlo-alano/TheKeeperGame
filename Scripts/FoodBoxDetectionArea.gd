extends Area3D

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
	if Globals.get_is_in_dialogue():
		return
	# Activate the ghost mesh to show delivery target
	for node in get_tree().get_nodes_in_group("objective_return_slots"):
		if str(node.get("expected_item_id")) == "food_box":
			node.set_return_objective_active(true)
	# Add task to taskbar
	if GlobalTracker.run_once_per_day("foodbox_task_added"):
		TasksManager.add_to_tasklist(1, "Put the food box away")
	if GlobalTracker.run_once_per_day("foodbox_day1b_intro"):
		Globals.start_dialogue("FoodBox_Day1B_Intro", true)
