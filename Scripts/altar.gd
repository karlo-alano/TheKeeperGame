extends StaticBody3D

func interact():
	if GlobalTracker.allTasksCompleted:
		Globals.start_dialogue("Monologue_Day1_G", true)
