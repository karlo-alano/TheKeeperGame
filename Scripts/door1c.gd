extends StaticBody3D

var _delivered := false

func interact():
	if GlobalTracker.current_day != 1:
		return
	if not GlobalTracker.mailCollected:
		return
	if _delivered:
		return
	_delivered = true
	GlobalTracker.letterInventory["lolo"]["delivered"] = true
	TasksManager.complete_subtask("Deliver Mails", "Go to Lolo Aurelio's unit")
	Globals.start_dialogue("Door1C_D1TaskDeliverMails", true)
