extends Node
signal show_interact_prompt(is_visible)
signal show_action_prompt(is_visible)

var Player: CharacterBody3D
var is_in_dialogue := false
var current_world_scene := ""
var current_world: Node3D = null
var _active_dialogue_timeline := ""
var _wait_for_mysterious_after_lolo := false
var _lolo_anchor_position := Vector3.ZERO
var _mysterious_wait_timer := 0.0
var _moved_two_meters_from_lolo := false
var _pending_monologue3b_on_journal_close := false
var _lock_player_for_monologue3a := false
var _pending_day3_paluto_objective := false

func _ready():
	Player = get_tree().get_first_node_in_group("Player")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	#start_dialogue("Dream_Trigger", true)
	
	change_viewport_world("res://Scenes/World_day3A.tscn")
	
func _on_dialogic_signal(argument):
	print("[Globals] Dialogic signal received:", argument)
	if argument == "startday1":
		GlobalTracker.set_current_day(1)
		change_viewport_world("res://Scenes/World_day1A.tscn")
	if argument == "startday2":
		GlobalTracker.set_current_day(2)
		change_viewport_world("")
	if argument == "startday3":
		GlobalTracker.set_current_day(3)
		change_viewport_world("res://Scenes/World_day3A.tscn")
	if argument == "startdream":
		change_viewport_world("res://Scenes/dream_sequence.tscn")
	if argument == "cutscene1":
		Items.items["door2c"].openDoor()
	if argument == "changescene1":
		change_viewport_world("res://Scenes/World_day1B.tscn")
	if argument == "cutscene2":
		if Characters.characters.has("forsythe") and Characters.characters["forsythe"] and is_instance_valid(Characters.characters["forsythe"]):
			if Characters.characters["forsythe"].has_method("disappear"):
				Characters.characters["forsythe"].disappear()
		DaySystem.dayInfo[1]["tasks"][0]["done"] = true

	if argument == "spawn_character_lolo":
		print("[Globals] spawn_character_lolo signal received")
		if not current_world:
			print("[Globals] No current_world cached")
			return
		var world = current_world
		# avoid duplicate spawns
		if world.has_node("Lolo"):
			print("[Globals] World already has node named Lolo; skipping spawn")
			return
		# instantiate Lolo scene
		var lolo_res = load("res://Scenes/lolo.tscn")
		if not lolo_res:
			print("[Globals] Failed to load res://Scenes/lolo.tscn")
			return
		var lolo_inst = lolo_res.instantiate()
		lolo_inst.name = "Lolo"
		# correct position and rotation from Day3 placement
		lolo_inst.position = Vector3(-12.0, 0.192, -8.81)
		lolo_inst.rotation.y = PI / 2.0
		lolo_inst.scale = Vector3(0.5, 0.5, 0.5)
		lolo_inst.add_to_group("interactable")

		# add DetectionArea (same as world Day1)
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

		# add radio as child (like Day1)
		var radio_res = load("res://Imports/radio/radio.tscn")
		if radio_res:
			var radio_inst = radio_res.instantiate()
			radio_inst.name = "radio"
			radio_inst.position = Vector3(1.8, 1.35, -0.58)
			radio_inst.rotation.y = PI / 2.0
			lolo_inst.add_child(radio_inst)

		world.add_child(lolo_inst)

		# update Day 3 objective after Mrs. Valenciano dialogue
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

		# refresh journal/book task UI immediately
		var book_after_spawn = world.find_child("book", true, false)
		if book_after_spawn:
			var page_after_spawn = book_after_spawn.get_node_or_null("Cube_003/Page1/SubViewport/BookContents")
			if page_after_spawn and page_after_spawn.has_method("showDay"):
				page_after_spawn.showDay(3)

		var ui_after_spawn = get_tree().root.find_child("UI", true, false)
		if ui_after_spawn and ui_after_spawn.has_method("show_journal_prompt"):
			ui_after_spawn.show_journal_prompt()

	# support Dialogic-driven journal updates. Usage in timeline:
	# signal_event: "journal:add:id|Title|Body|auto"  (optional 'auto' to open immediately)
	if typeof(argument) == TYPE_STRING and argument.begins_with("journal:add:"):
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
				var book = world.find_child("book", true, false)
				if book and book.has_method("add_entry"):
					book.add_entry(id, title, body, -1)
					emit_signal("show_action_prompt", true)
					if auto_open and book.has_method("openJournal"):
						book.openJournal()

	# simple update: "journal:update:id|Title|Body"
	if typeof(argument) == TYPE_STRING and argument.begins_with("journal:update:"):
		var payload2: String = argument.substr("journal:update:".length())
		var parts2: PackedStringArray = payload2.split("|")
		if parts2.size() >= 1:
			var id2 := parts2[0]
			var title2: String = parts2[1] if parts2.size() > 1 else ""
			var body2: String = parts2[2] if parts2.size() > 2 else ""
			var viewport2 = get_tree().root.find_child("SubViewport", true, false)
			if viewport2:
				var world2 = viewport2.get_node_or_null("World")
				if world2:
					var book2 = world2.find_child("book", true, false)
					if book2 and book2.has_method("update_entry"):
						var data := {}
						if title2 != "":
							data["title"] = title2
						if body2 != "":
							data["body"] = body2
						book2.update_entry(id2, data)
	
		

func change_viewport_world(new_scene_path: String):
	var viewport = get_tree().root.find_child("SubViewport", true, false)
	
	if viewport:
		var old_world = viewport.get_node_or_null("World")
		if old_world:
			old_world.queue_free()
		
		var new_world_res = load(new_scene_path)
		var new_world = new_world_res.instantiate()
		new_world.name = "World"
		# ensure the loaded world doesn't inherit an unexpected scale (prevents Jolt physics warnings)
		if typeof(new_world) == TYPE_OBJECT and new_world.has_method("set_scale"):
			new_world.scale = Vector3.ONE
		else:
			# try to sanitize transform basis if scale property isn't available
			new_world.transform = Transform3D(new_world.transform.basis.orthonormalized(), new_world.transform.origin)

		viewport.add_child(new_world)
		current_world = new_world

		# record which scene was loaded so other scripts can adapt behavior
		current_world_scene = new_scene_path
		if new_scene_path.find("World_day1") != -1:
			GlobalTracker.set_current_day(1)
		elif new_scene_path.find("World_day3A") != -1:
			GlobalTracker.set_current_day(3)
		
		await get_tree().process_frame
		Player = get_tree().get_first_node_in_group("Player")



func start_dialogue(timeline: String, is_monologue: bool = false):
	if timeline.find("/") != -1 and not timeline.contains("://"):
		timeline = timeline.get_file().trim_suffix("." + timeline.get_extension())
	_active_dialogue_timeline = timeline

	# Always connect timeline_ended to handle dialogue completion for all types
	Dialogic.timeline_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)

	if is_monologue and timeline == "Monologue3A":
		_lock_player_for_monologue3a = true
		is_in_dialogue = true
		if Player:
			Player.set_process(false)
			Player.set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Dialogic.start(timeline)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		await get_tree().process_frame
		_disable_dialogic_mouse()
		return

	if !is_monologue:
		is_in_dialogue = true
		Player.set_process_input(false)
		Player.set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Dialogic.start(timeline)
	
	if is_monologue:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# Wait one frame for Dialogic to finish building its layout
		await get_tree().process_frame
		_disable_dialogic_mouse()

func _disable_dialogic_mouse() -> void:
	var layout = Dialogic.Styles.get_layout_node()
	if layout:
		_set_mouse_filter_recursive(layout)

func _set_mouse_filter_recursive(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_mouse_filter_recursive(child)
		
func _on_dialogue_ended():
	is_in_dialogue = false

	if _active_dialogue_timeline == "Lolo_Day3_A":
		print("[Globals] Lolo_Day3_A ended; arming Mysterious watcher")
		_wait_for_mysterious_after_lolo = true
		_moved_two_meters_from_lolo = false
		_mysterious_wait_timer = 0.0
		if Characters.characters.has("lolo") and Characters.characters["lolo"] and is_instance_valid(Characters.characters["lolo"]):
			_lolo_anchor_position = Characters.characters["lolo"].global_position
			print("[Globals] Lolo anchor position (from Characters): %s" % _lolo_anchor_position)
		elif current_world and current_world.has_node("Lolo"):
			var lolo_node = current_world.get_node("Lolo")
			if lolo_node is Node3D:
				_lolo_anchor_position = lolo_node.global_position
				print("[Globals] Lolo anchor position (from world): %s" % _lolo_anchor_position)

	if _active_dialogue_timeline == "MysteriousMonologue":
		print("[Globals] MysteriousMonologue ended; updating tasks and opening journal")
		# Update Day 3 tasks to new list
		if DaySystem.dayInfo.has(3):
			DaySystem.dayInfo[3]["tasks"] = [
				{"name": "Clean the courtyard", "done": false},
				{"name": "Feed the cat", "done": false},
				{"name": "Water the plants", "done": false}
			]
			print("[Globals] Day 3 tasks updated")

		# Show journal prompt and open journal
		emit_signal("show_action_prompt", true)
		if current_world:
			print("[Globals] current_world found; looking for book...")
			var book = current_world.find_child("book", true, false)
			if book:
				print("[Globals] book found; opening journal...")
				if book.has_method("openJournal"):
					book.openJournal()
					# Refresh journal page with new tasks
					var page = book.get_node_or_null("Cube_003/Page1/SubViewport/BookContents")
					if page and page.has_method("showDay"):
						page.showDay(3)
						print("[Globals] Journal page refreshed with new tasks")
					# Connect to journal close signal to trigger Monologue3B
					if book.is_connected("journal_closed", Callable(self, "_on_journal_closed")):
						book.disconnect("journal_closed", Callable(self, "_on_journal_closed"))
					book.connect("journal_closed", Callable(self, "_on_journal_closed"), CONNECT_ONE_SHOT)
					_pending_monologue3b_on_journal_close = true
					print("[Globals] Connected to journal_closed signal")
				else:
					print("[Globals] book has no openJournal method")
			else:
				print("[Globals] book not found in world")

	if _lock_player_for_monologue3a:
		_lock_player_for_monologue3a = false
		Player.set_process(true)
		Player.set_physics_process(true)
		_pending_day3_paluto_objective = true
		_add_day3_paluto_objective()
	else:
		Player.set_process_input(true)
		Player.set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_active_dialogue_timeline = ""


func _process(delta: float) -> void:
	if not _wait_for_mysterious_after_lolo:
		return
	if is_in_dialogue:
		return
	if not Player or not is_instance_valid(Player):
		Player = get_tree().get_first_node_in_group("Player")
		if not Player:
			return

	if not _moved_two_meters_from_lolo:
		var distance = Player.global_position.distance_to(_lolo_anchor_position)
		if distance >= 2.0:
			print("[Globals] Player moved %.2f meters from Lolo; starting 3-second timer" % distance)
			_moved_two_meters_from_lolo = true
			_mysterious_wait_timer = 0.0
		return

	_mysterious_wait_timer += delta
	print("[Globals] Mysterious wait timer: %.1f / 3.0 seconds" % _mysterious_wait_timer)
	if _mysterious_wait_timer < 3.0:
		return

	_wait_for_mysterious_after_lolo = false
	_moved_two_meters_from_lolo = false
	_mysterious_wait_timer = 0.0
	print("[Globals] Timer complete; triggering MysteriousMonologue")
	if GlobalTracker.run_once_per_day("mysterious_monologue_day3"):
		print("[Globals] Starting MysteriousMonologue")
		start_dialogue("MysteriousMonologue", true)
	else:
		print("[Globals] MysteriousMonologue already ran today; skipping")


func _add_day3_paluto_objective() -> void:
	if not _pending_day3_paluto_objective:
		return
	_pending_day3_paluto_objective = false
	if DaySystem.dayInfo.has(3):
		var day3_tasks: Array = DaySystem.dayInfo[3]["tasks"]
		var objective_name := "Ask Mrs. Valenciano about paluto for Penny's birthday"
		var already_added := false
		for task in day3_tasks:
			if task.has("name") and task["name"] == objective_name:
				already_added = true
				break
		if not already_added:
			day3_tasks.append({"name": objective_name, "done": false})
			DaySystem.dayInfo[3]["tasks"] = day3_tasks

	var viewport = get_tree().root.find_child("SubViewport", true, false)
	if viewport:
		var world = viewport.get_node_or_null("World")
		if world:
			var book = world.find_child("book", true, false)
			if book and book.has_method("openJournal"):
				var page1 = book.get_node_or_null("Cube_003/Page1/SubViewport/BookContents")
				if page1 and page1.has_method("showDay"):
					page1.showDay(3)

	var ui = get_tree().root.find_child("UI", true, false)
	if ui and ui.has_method("show_journal_prompt"):
		ui.show_journal_prompt()
	

func _on_journal_closed() -> void:
	print("[Globals] _on_journal_closed() called")
	if not _pending_monologue3b_on_journal_close:
		print("[Globals] No pending Monologue3B; returning")
		return
	_pending_monologue3b_on_journal_close = false
	if GlobalTracker.run_once_per_day("monologue3b_day3"):
		print("[Globals] Starting Monologue3B")
		# Monologue3B plays as regular dialogue, player can move
		start_dialogue("Monologue3B", false)
	else:
		print("[Globals] Monologue3B already ran today; skipping")
	
