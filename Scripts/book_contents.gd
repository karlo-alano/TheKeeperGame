extends Control
@onready var DayLabel := $DayLabel
@onready var Tasks := $Tasks
@onready var DayCounter := $DayCounter



var currentDay = 1

func _ready():
	showDay(currentDay)
	
func showDay(day: int):
	var data = DaySystem.dayInfo[day]
	DayLabel.text = data["label"]
	DayCounter.text = data["counter"]
	
	# Build tasks text
	var tasks_text = ""
	for task in data["tasks"]:
		tasks_text += "• %s\n" % task["name"]
	
	Tasks.text = tasks_text
	
	
	
