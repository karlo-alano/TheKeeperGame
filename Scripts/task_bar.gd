extends PanelContainer

@onready var day_label = $VBoxContainer/HBoxContainer/DayLabel
@onready var day_counter = $VBoxContainer/HBoxContainer/DayCounter
@onready var task_list = $VBoxContainer/TaskList

const TaskItem = preload("res://Scenes/TaskItem.tscn")

func _ready():
	refresh()

func refresh():
	var day = GlobalTracker.current_day
	var label = DaySystem.get_label(day)
	day_label.text = label
	day_counter.text = ""

	for child in task_list.get_children():
		child.queue_free()

	var tasks = DaySystem.get_tasks(day)
	for task in tasks:
		var item = TaskItem.instantiate()
		task_list.add_child(item)
		item.setup(task["name"], task.get("done", false))
