extends StaticBody3D


func interact():
	if GlobalTracker.current_day == 1 and !GlobalTracker.letterInventory["lolo"]["delivered"]:
		if GlobalTracker.run_once_per_day("door1c_lolo"):
			Globals.start_dialogue("Lolo_Day1_C", false)
		GlobalTracker.letterInventory["lolo"]["delivered"] = true
	else:
		Globals.start_dialogue("ifLetterDelivered", true)
