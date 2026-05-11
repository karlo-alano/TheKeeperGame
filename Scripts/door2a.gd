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
	GlobalTracker.letterInventory["leus"]["delivered"] = true
	TasksManager.complete_subtask("Deliver Mails", "Go to Leus' unit")
	Globals.start_dialogue("Door2A_D1TaskDeliverMails", true)
