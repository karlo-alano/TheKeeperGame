extends Node
## Handles dialogue lifecycle: starting timelines, managing player lock state during monologues,
## and restoring player input after dialogue ends.

var player: CharacterBody3D:
	get:
		return Globals.Player

var is_in_dialogue := false
var _lock_player_for_monologue3a := false
var _pending_day3_paluto_objective := false


func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)


func start_dialogue(timeline: String, is_monologue: bool = false) -> void:
	if timeline.find("/") != -1 and not timeline.contains("://"):
		timeline = timeline.get_file().trim_suffix("." + timeline.get_extension())

	if is_monologue and timeline == "Monologue3A":
		_lock_player_for_monologue3a = true
		is_in_dialogue = true
		if player:
			player.set_process(false)
			player.set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Dialogic.start(timeline)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		await get_tree().process_frame
		_disable_dialogic_mouse()
		return

	if !is_monologue:
		is_in_dialogue = true
		if player:
			player.set_process_input(false)
			player.set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		is_in_dialogue = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	Dialogic.start(timeline)
	
	if is_monologue:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		await get_tree().process_frame
		_disable_dialogic_mouse()


func _on_timeline_ended() -> void:
	is_in_dialogue = false
	
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
	
	if _lock_player_for_monologue3a:
		_lock_player_for_monologue3a = false
		if is_instance_valid(player):
			player.set_process(true)
			player.set_physics_process(true)
		_pending_day3_paluto_objective = true
		_add_day3_paluto_objective()
	else:
		if is_instance_valid(player):
			player.set_process_input(true)
			player.set_physics_process(true)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _disable_dialogic_mouse() -> void:
	var layout = Dialogic.Styles.get_layout_node()
	if layout:
		_set_mouse_filter_recursive(layout)


func _set_mouse_filter_recursive(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_mouse_filter_recursive(child)


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
			var book = world.find_node("book", true, false)
			if book and book.has_method("openJournal"):
				var page1 = book.get_node_or_null("Cube_003/Page1/SubViewport/BookContents")
				if page1 and page1.has_method("showDay"):
					page1.showDay(3)

	var ui = get_tree().root.find_child("UI", true, false)
	if ui and ui.has_method("show_journal_prompt"):
		ui.show_journal_prompt()
