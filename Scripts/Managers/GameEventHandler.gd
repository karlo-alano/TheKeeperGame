extends Node
## Handles gameplay events: character spawning, cutscene logic, objective updates, and journal events.


func _get_scene_manager() -> Node:
	return get_parent().scene_manager


func handle_cutscene1() -> void:
	Items.items["door2c"].openDoor()


func handle_cutscene2() -> void:
	if Characters.characters.has("forsythe") and Characters.characters["forsythe"] and is_instance_valid(Characters.characters["forsythe"]):
		if Characters.characters["forsythe"].has_method("disappear"):
			Characters.characters["forsythe"].disappear()
	DaySystem.dayInfo[1]["tasks"][0]["done"] = true


func spawn_character_lolo() -> void:
	print("[GameEventHandler] spawn_character_lolo signal received")
	
	var scene_manager = _get_scene_manager()
	var world = scene_manager.current_world
	
	if not world:
		print("[GameEventHandler] No current_world cached")
		return
	
	# Avoid duplicate spawns
	if world.has_node("Lolo"):
		print("[GameEventHandler] World already has node named Lolo; skipping spawn")
		return
	
	# Instantiate Lolo scene
	var lolo_res = load("res://Scenes/lolo.tscn")
	if not lolo_res:
		print("[GameEventHandler] Failed to load res://Scenes/lolo.tscn")
		return
	
	var lolo_inst = lolo_res.instantiate()
	lolo_inst.name = "Lolo"
	
	# Correct position and rotation from Day3 placement
	lolo_inst.position = Vector3(-12.0, 0.192, -8.81)
	lolo_inst.rotation.y = PI / 2.0
	lolo_inst.scale = Vector3(0.5, 0.5, 0.5)
	lolo_inst.add_to_group("interactable")

	# Add DetectionArea (same as world Day1)
	var area = Area3D.new()
	area.name = "DetectionArea"
	area.set_script(load("res://Scripts/loloDetectionArea.gd"))
	var cs = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(4.424225, 4.3013, 7.614502)
	cs.shape = box
	cs.transform = Transform3D(Basis(), Vector3(-0.039604187, 1.65065, 3.307251))
	area.add_child(cs)
	area.connect("body_entered", Callable(area, "_on_body_entered"))
	lolo_inst.add_child(area)

	# Add radio as child (like Day1)
	var radio_res = load("res://Imports/radio/radio.tscn")
	if radio_res:
		var radio_inst = radio_res.instantiate()
		radio_inst.name = "radio"
		radio_inst.position = Vector3(1.8, 1.35, -0.58)
		radio_inst.rotation.y = PI / 2.0
		lolo_inst.add_child(radio_inst)

	world.add_child(lolo_inst)

	# Update Day 3 objective after Mrs. Valenciano dialogue
	if DaySystem.dayInfo.has(3):
		var day3_tasks: Array = DaySystem.dayInfo[3]["tasks"]
		var old_objective := "Ask Mrs. Valenciano about paluto for Penny's birthday"
		var new_objective := "Speak with Lolo Aurelio"
		var has_new_objective := false
		for task in day3_tasks:
			if task.has("name") and task["name"] == old_objective:
				task["done"] = true
			if task.has("name") and task["name"] == new_objective:
				has_new_objective = true
		if not has_new_objective:
			day3_tasks.append({"name": new_objective, "done": false})
		DaySystem.dayInfo[3]["tasks"] = day3_tasks

	# Refresh journal/book task UI immediately
	var book_after_spawn = world.find_child("book", true, false)
	if book_after_spawn:
		var page_after_spawn = book_after_spawn.get_node_or_null("Cube_003/Page1/SubViewport/BookContents")
		if page_after_spawn and page_after_spawn.has_method("showDay"):
			page_after_spawn.showDay(3)

	var ui_after_spawn = get_tree().root.find_child("UI", true, false)
	if ui_after_spawn and ui_after_spawn.has_method("show_journal_prompt"):
		ui_after_spawn.show_journal_prompt()


func handle_journal_add(argument: String) -> void:
	var payload: String = argument.substr("journal:add:".length())
	var parts: PackedStringArray = payload.split("|")
	var id := parts[0] if parts.size() > 0 else ""
	var title := parts[1] if parts.size() > 1 else id
	var body := parts[2] if parts.size() > 2 else ""
	var auto_open := parts.size() > 3 and parts[3] == "auto"
	
	var viewport = get_tree().root.find_child("SubViewport", true, false)
	if viewport:
		var world = viewport.get_node_or_null("World")
		if world:
			var book = world.find_node("book", true, false)
			if book and book.has_method("add_entry"):
				book.add_entry(id, title, body, -1)
				Globals.show_action_prompt.emit(true)
				if auto_open and book.has_method("openJournal"):
					book.openJournal()


func handle_journal_update(argument: String) -> void:
	var payload: String = argument.substr("journal:update:".length())
	var parts: PackedStringArray = payload.split("|")
	if parts.size() >= 1:
		var id := parts[0]
		var title: String = parts[1] if parts.size() > 1 else ""
		var body: String = parts[2] if parts.size() > 2 else ""
		
		var viewport = get_tree().root.find_child("SubViewport", true, false)
		if viewport:
			var world = viewport.get_node_or_null("World")
			if world:
				var book = world.find_node("book", true, false)
				if book and book.has_method("update_entry"):
					var data := {}
					if title != "":
						data["title"] = title
					if body != "":
						data["body"] = body
					book.update_entry(id, data)
