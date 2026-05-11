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
	visible = false
	call_deferred("refresh")

func refresh():
	var day = GlobalTracker.current_day
	if not taskbar_data.has(day):
		return
	var info = taskbar_data[day]
	day_label.text = info["label"]
	day_counter.text = info["counter"]

	for child in task_list.get_children():
		child.queue_free()

	var tasks: Array = TasksManager.task_list[day]["tasks"]
	var current_task = null
	for task in tasks:
		if not task["done"]:
			current_task = task
			break

	if current_task != null:
		var richtext_label = RichTextLabel.new()
		richtext_label.bbcode_enabled = true
		richtext_label.custom_minimum_size = Vector2(200, 30)
		richtext_label.fit_content = true
		var progress_text = TasksManager.get_task_progress_text(current_task["name"])
		if progress_text != "":
			richtext_label.text = "☐ %s  %s" % [current_task["name"], progress_text]
		else:
			richtext_label.text = "☐ %s" % current_task["name"]
		task_list.add_child(richtext_label)

		# Show subtasks if any
		var subtasks = TasksManager.get_subtasks(current_task["name"])
		for subtask in subtasks:
			var sub_label = Label.new()
			sub_label.add_theme_font_size_override("font_size", 12)
			if subtask["done"]:
				sub_label.text = "     ✓ %s" % subtask["name"]
				sub_label.modulate = Color(0.6, 0.6, 0.6)
			else:
				sub_label.text = "     ☐ %s" % subtask["name"]
			task_list.add_child(sub_label)

	visible = current_task != null

func play_add_task_audio():
	add_task_audio.play()
	
func play_complete_task_audio():
		complete_task_audio.play()
	
	
