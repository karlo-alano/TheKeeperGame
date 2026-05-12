extends StaticBody3D

var is_sleeping := false

func interact():
	if GlobalTracker.current_day != 1:
		return
	if is_sleeping:
		return

	# Hard check: "Check on Forsythe" must be done in state (not bypassed by debug flag)
	var forsythe_done := false
	var state_tasks = TasksManager.state.get(1, {}).get("tasks", [])
	for t in state_tasks:
		if t.get("name") == "Check on Forsythe" and t.get("done", false):
			forsythe_done = true
			break

	if not forsythe_done:
		if GlobalTracker.run_once_per_day("bed_not_yet"):
			Globals.start_dialogue("Bed_NotYet", true)
		return
	is_sleeping = true
	# run_once_per_day ensures this can't fire again even if bed.gd re-instantiates
	if not GlobalTracker.run_once_per_day("bed_sleep_day1"):
		return
	TasksManager.mark_task_done_by_name(1, "Take a nap")
	TasksManager.mark_state_task_done_by_name(1, "Take a nap")
	Globals.change_viewport_world("res://Scenes/World_day1B.tscn")
