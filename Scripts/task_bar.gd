extends PanelContainer

@onready var day_label = $VBoxContainer/HBoxContainer/DayLabel
@onready var day_counter = $VBoxContainer/HBoxContainer/DayCounter
@onready var task_list = $VBoxContainer/TaskList
@onready var complete_task_audio = $"../CompleteTask"
@onready var add_task_audio = $"../AddTask"

const TaskItem = preload("res://Scenes/TaskItem.tscn")

var taskbar_data := {
	1: {"label": "June 31", "counter": "2 days to go",
		"tasks": ["Pack lunch for Penny", "Deliver the letters"]},
	2: {"label": "", 
		"counter": "",
		"tasks": [
			
		]},
	3: {"label": "July 2", "counter": "Day 3",
		"tasks": ["Talk to Lolo Aurelio"]}
}

func _ready():
	Items.items["tasklist"] = self
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
	
	var tasklist = TasksManager.task_list
	print("Task list:", tasklist)
	for task in tasklist[day]["tasks"]:
		print("Adding task:", task)
		var richtext_label = RichTextLabel.new()
		richtext_label.bbcode_enabled = true
		richtext_label.custom_minimum_size = Vector2(200, 30)
		richtext_label.fit_content = true
		
		if task["done"]:
			richtext_label.text = "☑ %s" % task["name"]
		else:
			richtext_label.text = "☐ %s" % task["name"]
		
		task_list.add_child(richtext_label)
	print("Refresh complete")

func play_add_task_audio():
	add_task_audio.play()
	
func play_complete_task_audio():
		complete_task_audio.play()
	
	
