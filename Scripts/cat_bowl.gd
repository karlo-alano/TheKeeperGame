extends Node3D

const FEED_DURATION := 4.0
var slot := "Cat Bowl"
var current_feed_time := 0.0
var _fully_fed := false

var _full_bowl: Node3D = null

func _ready() -> void:
	# Find the CatBowlWithFood node in the world and hide it at start
	_full_bowl = get_tree().root.find_child("CatBowlWithFood", true, false)
	if _full_bowl:
		_full_bowl.visible = false

func feed(delta: float) -> void:
	if _fully_fed:
		return
	current_feed_time += delta
	if current_feed_time >= FEED_DURATION:
		_fully_fed = true
		TasksManager.update_task_progress("Feed Cally", 1)
		TasksManager.mark_task_done_by_name(1, "Feed Cally")
		TasksManager.add_put_it_back_task(1, "Cat Bowl")
		_show_full_bowl()
		# After feeding, prompt the next task on the taskbar
		TasksManager.add_to_tasklist_delayed(1, "Go to the mailbox", 3.0)

func reset_progress() -> void:
	current_feed_time = 0.0

func _show_full_bowl() -> void:
	# Hide empty bowl, show full bowl
	visible = false
	if _full_bowl:
		_full_bowl.visible = true
