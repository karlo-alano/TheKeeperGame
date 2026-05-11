extends StaticBody3D

var is_open := false
var slot := "Penny's Door"
var isOpenedOnce := false
var _forsythe_checked := false


func _ready():
	Items.items["door2c"] = self
	add_to_group("interactable")
	

func openDoor():
	$"../Door2C".play("OpenDoor")
	
func interact():
	if GlobalTracker.current_day == 1 and not _forsythe_checked:
		# Hard check: all 5 mail subtasks must be done (not bypassed by debug flag)
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
