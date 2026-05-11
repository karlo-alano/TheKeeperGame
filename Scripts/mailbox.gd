extends StaticBody3D

var _mail_collected := false

func interact():
	if GlobalTracker.current_day != 1:
		return

	if not TasksManager.is_task_unlocked(1, "Deliver Mails"):
		return

	if not _mail_collected:
		_mail_collected = true
		GlobalTracker.mailCollected = true
		# Mark "Go to the mailbox" done on the taskbar
		TasksManager.mark_task_done_by_name(1, "Go to the mailbox")
		# Add "Deliver Mails" task to the taskbar (with subtasks + progress)
		TasksManager.add_to_tasklist_delayed(1, "Deliver Mails", 2.0)
		# Lolo Aurelio disappears after getting the mails (with radio)
		_remove_lolo()

	if GlobalTracker.run_once_per_day("mailbox_day1_intro"):
		Globals.start_dialogue("Timelines/Monologue_Day1_E", true)

func _remove_lolo() -> void:
	# Find and remove ALL nodes named "Lolo" in the entire tree
	var found = get_tree().root.find_child("Lolo", true, false)
	while found and is_instance_valid(found):
		var parent = found.get_parent()
		if parent:
			parent.remove_child(found)
		found.queue_free()
		found = get_tree().root.find_child("Lolo", true, false)
