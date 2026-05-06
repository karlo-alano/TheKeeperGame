extends Node
## Routes Dialogic signal events to appropriate handlers based on signal type.


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _on_dialogic_signal(argument: String) -> void:
	print("[SignalRouter] Dialogic signal received:", argument)
	
	var globals = get_parent()
	var scene_manager = globals.scene_manager
	var game_event_handler = globals.game_event_handler
	
	# Route to specific handlers
	match argument:
		"startday1":
			_handle_start_day(1, "res://Scenes/World_day1A.tscn", scene_manager)
		"startday2":
			_handle_start_day(2, "", scene_manager)
		"startday3":
			_handle_start_day(3, "res://Scenes/World_day3A.tscn", scene_manager)
		"startdream":
			scene_manager.change_viewport_world("res://Scenes/dream_sequence.tscn")
		"cutscene1":
			game_event_handler.handle_cutscene1()
		"changescene1":
			scene_manager.change_viewport_world("res://Scenes/World_day1B.tscn")
		"cutscene2":
			game_event_handler.handle_cutscene2()
		"spawn_character_lolo":
			game_event_handler.spawn_character_lolo()
		_:
			# Check for journal events
			if argument.begins_with("journal:add:"):
				game_event_handler.handle_journal_add(argument)
			elif argument.begins_with("journal:update:"):
				game_event_handler.handle_journal_update(argument)


func _handle_start_day(day: int, scene_path: String, scene_manager: Node) -> void:
	GlobalTracker.set_current_day(day)
	if scene_path != "":
		scene_manager.change_viewport_world(scene_path)
