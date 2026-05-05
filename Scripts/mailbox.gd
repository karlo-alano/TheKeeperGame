extends StaticBody3D

func interact():
	if GlobalTracker.current_day != 1:
		return
	if GlobalTracker.run_once_per_day("mailbox_day1_intro"):
		Globals.start_dialogue("Timelines/Monologue_Day1_E", true)
