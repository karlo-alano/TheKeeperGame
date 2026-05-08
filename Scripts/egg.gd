extends Node3D

var hasEgg := false
@onready var sound := get_node_or_null("../Blip")

func obtain():
	print("[egg] obtain() called on", get_path(), "hasEgg=" , hasEgg)
	if hasEgg:
		print("[egg] already obtained, ignoring")
		return
	GlobalTracker.eggCounter += 1
	hasEgg = true
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
	if GlobalTracker.eggCounter == 6:
		GlobalTracker.eggTaskCompleted = true
		DaySystem.set_task_done(1, 1, true)

func despawn():
	# Safely free this node (deferred to avoid tree modification during physics callbacks)
	if is_inside_tree():
		call_deferred("queue_free")
	else:
		queue_free()
