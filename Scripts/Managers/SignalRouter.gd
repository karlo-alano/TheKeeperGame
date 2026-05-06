extends Node
## Routes Dialogic signal events to appropriate handlers based on signal type.

var _pending_scene_path := ""
var _pending_day := -1


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)


func _on_dialogic_signal(argument: String) -> void:
	print("[SignalRouter] Dialogic signal received:", argument)
	if _is_dialogic_test_scene() and not argument.begins_with("journal:") and argument != "show_journal_prompt":
		print("[SignalRouter] Ignoring gameplay signal during Dialogic timeline test:", argument)
		return
	
	var globals = get_parent()
	var scene_manager = globals.scene_manager
	var game_event_handler = globals.game_event_handler
	
	# Route to specific handlers
	match argument:
		"startday1":
			_queue_scene_change(1, "res://Scenes/World_day1A.tscn")
		"startday2":
			_queue_scene_change(2, "")
		"startday3":
			_queue_scene_change(3, "res://Scenes/World_day3A.tscn")
		"startdream":
			_queue_scene_change(-1, "res://Scenes/dream_sequence.tscn")
		"cutscene1":
			game_event_handler.handle_cutscene1()
		"changescene1":
			_queue_scene_change(-1, "res://Scenes/World_day1B.tscn")
		"cutscene2":
			game_event_handler.handle_cutscene2()
		"spawn_character_lolo":
			game_event_handler.spawn_character_lolo()
		"show_journal_prompt", "journal:prompt":
			_show_journal_prompt()
		_:
			# Check for journal events
			if argument.begins_with("journal:add:"):
				game_event_handler.handle_journal_add(argument)
			elif argument.begins_with("journal:update:"):
				game_event_handler.handle_journal_update(argument)
			elif argument.begins_with("objectives:update:"):
				game_event_handler.handle_objectives_update(argument)


func _queue_scene_change(day: int, scene_path: String) -> void:
	_pending_day = day
	_pending_scene_path = scene_path


func _on_timeline_ended() -> void:
	if _pending_day != -1:
		GlobalTracker.set_current_day(_pending_day)
		_pending_day = -1

	if _pending_scene_path != "":
		var scene_manager = get_parent().scene_manager
		scene_manager.change_viewport_world(_pending_scene_path)
		_pending_scene_path = ""


func _show_journal_prompt() -> void:
	var ui = get_tree().root.find_child("UI", true, false)
	if ui and ui.has_method("show_journal_prompt"):
		ui.show_journal_prompt()


func _is_dialogic_test_scene() -> bool:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return false
	var scene_path: String = current_scene.scene_file_path
	return scene_path.ends_with("addons/dialogic/Editor/TimelineEditor/test_timeline_scene.tscn")
