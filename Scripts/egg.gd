extends Node3D

var hasEgg := false
@onready var sound := get_node_or_null("../Blip")

func obtain():
	if hasEgg:
		return
	if not TasksManager.is_task_unlocked(1, "Collect eggs"):
		return
	GlobalTracker.eggCounter += 1
	hasEgg = true
	TasksManager.update_task_progress("Collect eggs", GlobalTracker.eggCounter)
	# immediate feedback: hide the whole egg root (mesh is a sibling of this StaticBody3D)
	var root = get_parent()
	if root:
		# hide the visual mesh(s)
		for c in root.get_children():
			if c is MeshInstance3D:
				c.visible = false
			if c is CollisionShape3D:
				c.disabled = true
		# hide the parent container as a fallback
		root.hide()
	else:
		# fallback to hiding this node
		hide()
	# play pickup sound if available
	if sound and sound.has_method("play"):
		sound.play()
	# free the whole egg root deferred to avoid tree modification during physics callbacks
	if root and is_instance_valid(root):
		root.call_deferred("queue_free")
	else:
		despawn()
	if GlobalTracker.current_day == 1:
		if GlobalTracker.eggCounter == 6:
			GlobalTracker.eggTaskCompleted1 = true
			TasksManager.set_task_done(1, 1, true)
			GlobalTracker.eggCounter == null
	if GlobalTracker.current_day == 2:
		if GlobalTracker.eggCounter == 6:
			GlobalTracker.eggTaskCompleted2 = true
			TasksManager.mark_task_done(2, 0)
			GlobalTracker.eggCounter == null
	

func despawn():
	if is_inside_tree():
		call_deferred("queue_free")
	else:
		queue_free()
