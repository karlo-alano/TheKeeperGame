extends Node

signal task_done_changed(day: int, index: int, done: bool)

# Templates: immutable per-day metadata and default task list
var day_templates := {
	1: {"label": "June 31",
		"tasks": [
			{"name": "Water the Garden", "done": false},
			{"name": "Collect eggs", "done": false},
			{"name": "Sweep litter", "done": false},
			{"name": "Feed Cally", "done": false}
		]
	},
	2: {"label": "July 1",
		"tasks": [
			{"name": "Collect rent", "done": false},
			{"name": "Water plants", "done": false},
			{"name": "Accompany cat", "done": false}
		]
	},
	3: {"label": "July 2",
		"tasks": [
			{"name": "Ask Mrs. Valenciano about paluto for Penny's birthday", "done": false}
		]
	}
}

var task_list := {
	1: {"tasks": [
		]
	},
	2: {"tasks": [
		]
	},
	3: {"tasks": [
		]
	},
}


func mark_task_done_by_name(day: int, task_name: String) -> void:
	var tasks: Array = task_list[day]["tasks"]
	for i in range(tasks.size()):
		if tasks[i]["name"] == task_name:
			mark_task_done(day, i)
			return
	# task not in task_list yet — add it as already done so it animates out
	tasks.append({"name": task_name, "done": false})
	mark_task_done(day, tasks.size() - 1)

func add_to_tasklist(day: int, name: String) -> void:
	task_list[day]["tasks"].append({"name": name, "done": false,})
	Items.items["tasklist"].play_add_task_audio()
	Items.items["tasklist"].refresh()

func add_to_tasklist_delayed(day: int, name: String, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	add_to_tasklist(day, name)

func mark_task_done(day: int, task_index: int) -> void:
	var tasks: Array = task_list[day]["tasks"]
	if task_index < 0 or task_index >= tasks.size():
		return
	Items.items["tasklist"].play_complete_task_audio()
	tasks[task_index]["done"] = true
	set_task_done(day, task_index, true)
	Items.items["tasklist"].refresh()
	await get_tree().create_timer(2.0).timeout
	if task_index < tasks.size():
		tasks.remove_at(task_index)
		Items.items["tasklist"].refresh()
	


# Mutable state: current tasks and journal per day
var state := {}

func _ready() -> void:
	for day in day_templates.keys():
		if not state.has(day):
			state[day] = {"tasks": _deep_copy_tasks(day_templates[day]["tasks"]), "journal": ""}

func _deep_copy_tasks(tasks: Array) -> Array:
	var out := []
	for i in range(tasks.size()):
		var t = tasks[i]
		out.append({"name": t["name"], "done": t.has("done") and t["done"] or false, "unlocked": i == 0})
	return out

# Getters
func get_label(day: int) -> String:
	return day_templates[day]["label"] if day_templates.has(day) else ""

func get_tasks(day: int) -> Array:
	if state.has(day) and state[day].has("tasks"):
		return state[day]["tasks"]
	if day_templates.has(day):
		return _deep_copy_tasks(day_templates[day]["tasks"])
	return []

func get_journal(day: int) -> String:
	return state[day]["journal"] if state.has(day) and state[day].has("journal") else ""

# Setters
func set_tasks(day: int, tasks: Array) -> void:
	if not state.has(day):
		state[day] = {"tasks": [], "journal": ""}
	state[day]["tasks"] = tasks

func set_journal(day: int, text: String) -> void:
	if not state.has(day):
		state[day] = {"tasks": [], "journal": ""}
	state[day]["journal"] = text

func add_task(day: int, task_name: String) -> void:
	if not state.has(day):
		state[day] = {"tasks": [], "journal": ""}
	var tasks: Array = state[day]["tasks"]
	for t in tasks:
		if t.has("name") and t["name"] == task_name:
			return
	tasks.append({"name": task_name, "done": false})
	state[day]["tasks"] = tasks

func set_task_done(day: int, index: int, done: bool) -> void:
	if not state.has(day):
		print("[DaySystem] set_task_done: state missing for day ", day)
		return
	var tasks: Array = state[day].get("tasks", [])
	if index >= 0 and index < tasks.size():
		tasks[index]["done"] = done
		if done and index + 1 < tasks.size():
			tasks[index + 1]["unlocked"] = true
		state[day]["tasks"] = tasks
		# sync task_list by name so index mismatch doesn't matter
		var task_name: String = tasks[index]["name"]
		var tl: Array = task_list[day]["tasks"]
		for i in range(tl.size()):
			if tl[i]["name"] == task_name:
				mark_task_done(day, i)
				break
		print("[DaySystem] Task %d on day %d marked done=%s" % [index, day, done])
		task_done_changed.emit(day, index, done)
	else:
		print("[DaySystem] set_task_done: index %d out of range (size=%d)" % [index, tasks.size()])
