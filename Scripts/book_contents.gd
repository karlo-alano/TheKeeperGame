extends Control
@onready var DayLabel := $DayLabel
@onready var Tasks := $Tasks
@onready var DayCounter := $DayCounter



var currentDay = 1
var entries := {}

func _ready():
	showDay(currentDay)
	
func showDay(day: int):
	var data = DaySystem.dayInfo[day]
	DayLabel.text = data["label"]
	DayCounter.text = data["counter"]
	var supports_bbcode := Tasks is RichTextLabel
	if supports_bbcode and not Tasks.bbcode_enabled:
		Tasks.bbcode_enabled = true
	
	var tasks_text = ""
	for task in data["tasks"]:
		if task["done"]:
			if supports_bbcode:
				tasks_text += "• [s]%s[/s]\n" % task["name"]
			else:
				tasks_text += "• %s (done)\n" % task["name"]
		else:
			tasks_text += "• %s\n" % task["name"]
	

	# Append journal entries for this day after tasks
	var entries_text := ""
	for id in entries.keys():
		var e = entries[id]
		if not e.has("day") or e["day"] == day:
			entries_text += "\n%s — %s\n%s\n" % [e.get("title", id), e.get("time", ""), e.get("body", "")]

	Tasks.text = tasks_text + entries_text

	# expose currentDay for external callers
	currentDay = day
	return

func add_entry(id:String, title:String, body:String, day:int = -1) -> void:
	# store the entry and refresh if visible
	entries[id] = {"title": title, "body": body, "time": str(Time.get_unix_time_from_system()), "day": day}
	showDay(currentDay)

func update_entry(id:String, data:Dictionary) -> void:
	if entries.has(id):
		entries[id].update(data)
		showDay(currentDay)

func get_entry(id:String) -> Dictionary:
	return entries.get(id, {})
	
	
	
