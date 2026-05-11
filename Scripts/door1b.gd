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
	GlobalTracker.letterInventory["lorie"]["delivered"] = true
	TasksManager.complete_subtask("Deliver Mails", "Go to Lorie's unit")
	Globals.start_dialogue("Door1B_D1TaskDeliverMails", true)
