extends Node

signal task_done_changed(day: int, index: int, done: bool)

## ─── DEBUG: Set to true to skip all task gating (lets you interact with anything) ───
const DEBUG_SKIP_TASK_GATES := true

## Task progress tracking: { "task_name": { "current": 0, "total": N } }
var task_progress := {
	"Water the Garden": {"current": 0, "total": 2},
	"Collect eggs": {"current": 0, "total": 6},
	"Sweep trash": {"current": 0, "total": 6},
	"Feed Cally": {"current": 0, "total": 1},
	"Deliver Mails": {"current": 0, "total": 5},
}

## Subtasks: { "task_name": [ {"name": "...", "done": false}, ... ] }
var task_subtasks := {
	"Deliver Mails": [
		{"name": "Go to the Valenciano's unit", "done": false},
		{"name": "Go to Lorie's unit", "done": false},
		{"name": "Go to Lolo Aurelio's unit", "done": false},
		{"name": "Go to Leus' unit", "done": false},
		{"name": "Go to Kei and Dale's unit", "done": false},
	]
}

func update_task_progress(task_name: String, current: int) -> void:
	if task_progress.has(task_name):
		task_progress[task_name]["current"] = current
		Items.items["tasklist"].refresh()

func complete_subtask(task_name: String, subtask_name: String) -> void:
	if not task_subtasks.has(task_name):
		return
	for subtask in task_subtasks[task_name]:
		if subtask["name"] == subtask_name and not subtask["done"]:
			subtask["done"] = true
			# Also update progress count
			if task_progress.has(task_name):
				task_progress[task_name]["current"] += 1
			Items.items["tasklist"].refresh()
			# Check if all subtasks are done
			var all_done := true
			for s in task_subtasks[task_name]:
				if not s["done"]:
					all_done = false
					break
			if all_done:
				mark_task_done_by_name(1, task_name)
				mark_state_task_done_by_name(1, task_name)
				# After Deliver Mails is done, add next task
				if task_name == "Deliver Mails":
					add_to_tasklist_delayed(1, "Check on Forsythe", 2.0)
			return

func get_task_progress_text(task_name: String) -> String:
	if task_progress.has(task_name):
		var p = task_progress[task_name]
		return "%d/%d" % [p["current"], p["total"]]
	return ""

func get_subtasks(task_name: String) -> Array:
	if task_subtasks.has(task_name):
		return task_subtasks[task_name]
	return []

# Templates: immutable per-day metadata and default task list
var day_templates := {
	1: {"label": "June 31",
		"tasks": [
			{"name": "Water the Garden", "done": false},
			{"name": "Collect eggs", "done": false},
			{"name": "Sweep trash", "done": false},
			{"name": "Feed Cally", "done": false},
			{"name": "Deliver Mails", "done": false},
			{"name": "Check on Forsythe", "done": false},
			{"name": "Take a nap", "done": false}
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

func mark_state_task_done_by_name(day: int, task_name: String) -> void:
	if not state.has(day):
		return
	var tasks: Array = state[day].get("tasks", [])
	for i in range(tasks.size()):
		if tasks[i]["name"] == task_name:
			set_task_done(day, i, true)
			return

## Returns true if the given task is allowed to be started (previous task is done).
## First task of the day is always unlocked.
func is_task_unlocked(day: int, task_name: String) -> bool:
	if DEBUG_SKIP_TASK_GATES:
		return true
	if not state.has(day):
		return false
	var tasks: Array = state[day].get("tasks", [])
	for i in range(tasks.size()):
		if tasks[i]["name"] == task_name:
			if i == 0:
				return true
			return tasks[i - 1].get("done", false)
	# Task not found in templates — allow by default
	return true

func add_to_tasklist(day: int, name: String) -> void:
	task_list[day]["tasks"].append({"name": name, "done": false,})
	Items.items["tasklist"].play_add_task_audio()
	Items.items["tasklist"].refresh()

func add_to_tasklist_delayed(day: int, name: String, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	add_to_tasklist(day, name)

func _find_task_index(day: int, task_name: String, item_key: String = "") -> int:
	var tasks: Array = task_list[day]["tasks"]
	for i in range(tasks.size()):
		if tasks[i].get("name", "") != task_name:
			continue
		if item_key == "" or tasks[i].get("item_key", "") == item_key:
			return i
	return -1

func add_put_it_back_task(day: int, item_key: String = "") -> void:
	var existing := _find_task_index(day, "Put it back", item_key)
	if existing != -1 and not task_list[day]["tasks"][existing].get("done", false):
		# Ensure the drop outline is active even if task already existed.
		_activate_return_zone(item_key)
		_set_put_back_objective_ghost(item_key, true)
		return
	task_list[day]["tasks"].insert(0, {"name": "Put it back", "done": false, "item_key": item_key})
	_activate_return_zone(item_key)
	_set_put_back_objective_ghost(item_key, true)
	Items.items["tasklist"].play_add_task_audio()
	Items.items["tasklist"].refresh()

func complete_put_it_back_task(day: int, item_key: String = "") -> bool:
	var idx := _find_task_index(day, "Put it back", item_key)
	if idx == -1:
		return false
	mark_task_done(day, idx)
	return true


func _put_back_expected_item_id(item_key: String) -> String:
	match item_key:
		"Garden Area":
			return "watering_can"
		"Trash Area":
			return "walis"
		"Cat Bowl":
			return "cat_food"
		_:
			return ""


func _set_put_back_objective_ghost(item_key: String, visible: bool) -> void:
	var want_id := _put_back_expected_item_id(item_key)
	if want_id == "":
		return
	for node in get_tree().get_nodes_in_group("objective_return_slots"):
		if str(node.get("expected_item_id")) != want_id:
			continue
		if node.has_method("set_return_objective_active"):
			node.set_return_objective_active(visible)

func _activate_return_zone(item_key: String) -> void:
	var zone_name := ""
	match item_key:
		"Garden Area":
			zone_name = "WateringCanReturnZone"
		"Trash Area":
			zone_name = "WalisReturnZone"
		"Cat Bowl":
			zone_name = "CatFoodReturnZone"
		_:
			return
	var zone = get_tree().root.find_child(zone_name, true, false)
	if zone and zone.has_method("activate"):
		zone.activate()

func mark_task_done(day: int, task_index: int) -> void:
	var tasks: Array = task_list[day]["tasks"]
	if task_index < 0 or task_index >= tasks.size():
		return
	if tasks[task_index].get("done", false):
		return
	if str(tasks[task_index].get("name", "")) == "Put it back":
		_set_put_back_objective_ghost(str(tasks[task_index].get("item_key", "")), false)
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
				tl[i]["done"] = done
				break
		print("[DaySystem] Task %d on day %d marked done=%s" % [index, day, done])
		task_done_changed.emit(day, index, done)
	else:
		print("[DaySystem] set_task_done: index %d out of range (size=%d)" % [index, tasks.size()])
