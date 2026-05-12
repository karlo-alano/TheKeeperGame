extends StaticBody3D

var _talked := false

func interact():
	if Globals.get_is_in_dialogue():
		return
	if GlobalTracker.current_day != 1:
		return
	if not TasksManager.is_task_unlocked(1, "Talk to Lolo Aurelio"):
		return
	if _talked:
		return
	_talked = true
	TasksManager.mark_task_done_by_name(1, "Talk to Lolo Aurelio")
	Globals.start_dialogue("Lolo_Day1B_A", false)
	# After dialogue ends, add next task
	await Dialogic.timeline_ended
	TasksManager.add_to_tasklist_delayed(1, "Check on Forsythe", 1.5)
