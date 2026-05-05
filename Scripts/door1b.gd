extends StaticBody3D

func interact():
	if GlobalTracker.current_day == 1 and !GlobalTracker.letterInventory["kei&dale"]["delivered"]:
		if GlobalTracker.run_once_per_day("door1b_keidale"):
			Globals.start_dialogue("KeiDale_Day1_A", false)
		var player = get_tree().get_first_node_in_group("Player")
		await get_tree().create_timer(3.0).timeout
		player.letterAnimation.play("give_letter")
		GlobalTracker.letterInventory["kei&dale"]["delivered"] = true
	else:
		Globals.start_dialogue("ifLetterDelivered", true)
	
	
