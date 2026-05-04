extends StaticBody3D

func interact():
	if !GlobalTracker.letterInventory["leus"]["delivered"]:
		Globals.start_dialogue("Leus_Day1_A", false)
		var player = get_tree().get_first_node_in_group("Player")
		await get_tree().create_timer(3.0).timeout
		player.letterAnimation.play("give_letter")
		GlobalTracker.letterInventory["leus"]["delivered"] = true
	else:
		Globals.start_dialogue("ifLetterDelivered", true)
