extends PanelContainer

@onready var day_label = $VBoxContainer/HBoxContainer/DayLabel
@onready var day_counter = $VBoxContainer/HBoxContainer/DayCounter
@onready var task_list = $VBoxContainer/TaskList

const TaskItem = preload("res://Scenes/TaskItem.tscn")

var taskbar_data := {
	1: {"label": "June 31", "counter": "2 days to go",
		"tasks": ["Pack lunch for Penny", "Deliver the letters"]},
	2: {"label": "July 1", "counter": "1 day to go",
		"tasks": ["Collect rent", "Water the plants"]},
	3: {"label": "July 2", "counter": "Day 3",
		"tasks": ["Talk to Lolo Aurelio"]}
}

func _ready():
	refresh()

func refresh():
	var day = GlobalTracker.current_day
	if not taskbar_data.has(day):
		return
	var info = taskbar_data[day]
	day_label.text = info["label"]
	day_counter.text = info["counter"]
	for child in task_list.get_children():
		child.queue_free()
	for task_name in info["tasks"]:
		var item = TaskItem.instantiate()
		task_list.add_child(item)
		item.setup(task_name)
