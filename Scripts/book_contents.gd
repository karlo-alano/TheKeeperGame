extends Control

@onready var DayLabel := $DayLabel
@onready var Tasks := $Tasks
@onready var DayCounter := $DayCounter

var currentDay = 1
var entries := {}


func _ready():
	showDay(currentDay)


func showDay(day: int):
	var label = TasksManager.get_label(day)
	DayLabel.text = label
	DayCounter.text = ""

	var supports_bbcode := Tasks is RichTextLabel
	if supports_bbcode and not Tasks.bbcode_enabled:
		Tasks.bbcode_enabled = true

	# Build tasks text from DaySystem state
	var tasks_text = ""
	var tasks := TasksManager.get_tasks(day)
	for task in tasks:
		if task.has("done") and task["done"]:
			if supports_bbcode:
				tasks_text += "• [s]%s[/s]\n" % task["name"]
			else:
				tasks_text += "• %s (done)\n" % task["name"]
		else:
			tasks_text += "• %s\n" % task["name"]

	# Pull journal entry directly from DaySystem
	var journal_text := ""
	var entry := TasksManager.get_journal(day)
	if entry != "":
		journal_text = "\n——————————\n%s" % entry

	Tasks.text = tasks_text + journal_text
	currentDay = day


func add_entry(id: String, title: String, body: String, day: int = -1) -> void:
	entries[id] = {"title": title, "body": body, "time": str(Time.get_unix_time_from_system()), "day": day}
	showDay(currentDay)


func update_entry(id: String, data: Dictionary) -> void:
	if entries.has(id):
		entries[id].update(data)
		showDay(currentDay)


func get_entry(id: String) -> Dictionary:
	return entries.get(id, {})
