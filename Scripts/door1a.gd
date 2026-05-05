extends StaticBody3D


func interact():
	# defensive access: ensure the inventory has the key before indexing
	if GlobalTracker.current_day == 1 and GlobalTracker.letterInventory.has("thevalencianos") and not GlobalTracker.letterInventory["thevalencianos"]["delivered"]:
		if GlobalTracker.run_once_per_day("door1a_valencianos"):
			Globals.start_dialogue("ValencianoFam_Day1_A", false)
		var player = get_tree().get_first_node_in_group("Player")
		await get_tree().create_timer(3.0).timeout
		player.letterAnimation.play("give_letter")
		GlobalTracker.letterInventory["thevalencianos"]["delivered"] = true
	else:
		Globals.start_dialogue("ifLetterDelivered", true)
