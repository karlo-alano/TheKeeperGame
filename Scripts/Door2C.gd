extends StaticBody3D

var is_open := false
var slot := "Penny's Door"
var isOpenedOnce := false
var _forsythe_checked := false


func _ready():
	Items.items["door2c"] = self
	add_to_group("interactable")
	# Hide LoloAfterForsythe until Check on Forsythe task is done
	call_deferred("_hide_lolo_after_forsythe")

func _hide_lolo_after_forsythe() -> void:
	var node = get_tree().root.find_child("LoloAfterForsythe", true, false)
	if node:
		node.visible = false
	

func openDoor():
	$"../Door2C".play("OpenDoor")
	
func interact():
	if GlobalTracker.current_day == 1 and not _forsythe_checked:
		# Day1B: Check on Forsythe (after talking to Lolo)
		if TasksManager.task_list[1]["tasks"].any(func(t): return t["name"] == "Check on Forsythe" and not t["done"]):
			_forsythe_checked = true
			TasksManager.mark_task_done_by_name(1, "Check on Forsythe")
			Globals.start_dialogue("Forsythe_Day1B", true)
			await Dialogic.timeline_ended
			TasksManager.add_to_tasklist_delayed(1, "Return to the party", 1.5)
			return
		# Day1A: Check on Forsythe (after mail deliveries)
		var subtasks = TasksManager.get_subtasks("Deliver Mails")
		var all_delivered := subtasks.size() > 0
		for s in subtasks:
			if not s["done"]:
				all_delivered = false
				break
		if not all_delivered:
			return
		_forsythe_checked = true
		TasksManager.mark_task_done_by_name(1, "Check on Forsythe")
		TasksManager.mark_state_task_done_by_name(1, "Check on Forsythe")
		# Show LoloAfterForsythe now
		var lolo_after = get_tree().root.find_child("LoloAfterForsythe", true, false)
		if lolo_after:
			lolo_after.visible = true
		# Add "Take a nap" to taskbar after a delay
		TasksManager.add_to_tasklist_delayed(1, "Take a nap", 2.0)
		Globals.start_dialogue("Forsythe_D1TaskCheckForsythe", true)
		return
	

	# Day 2 behavior
	if !is_open:
		if GlobalTracker.current_day == 2 and !isOpenedOnce:
			Globals.start_dialogue("monologue", false)
		$"../Door2C".play("OpenDoor")
		$"../OpenSound".play()
		is_open = !is_open
	else:
		$"../Door2C".play("CloseDoor")
		await Globals.wait(0.3)
		$"../CloseSound".play()
		is_open = !is_open
