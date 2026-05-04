extends StaticBody3D


func interact():
	if !GlobalTracker.letterInventory["lolo"]["delivered"]:
		Globals.start_dialogue("Lolo_Day1_C", false)
		GlobalTracker.letterInventory["lolo"]["delivered"] = true
	else:
		Globals.start_dialogue("ifLetterDelivered", true)
