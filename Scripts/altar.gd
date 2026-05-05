extends StaticBody3D

func interact():
	if GlobalTracker.current_day == 1 and GlobalTracker.allTasksCompleted and GlobalTracker.run_once_per_day("altar_day1_g"):
		Globals.start_dialogue("Monologue_Day1_G", true)
