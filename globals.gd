extends Node
## Central autoload for global state and manager coordination.
## Delegates specific logic to specialized managers.

signal show_interact_prompt(is_visible)
signal show_action_prompt(is_visible)

var Player: CharacterBody3D

# Manager references
var dialogue_manager: Node
var scene_manager: Node
var game_event_handler: Node
var signal_router: Node

# Internal pending flags (kept for compatibility with older code)
var _pending_monologue3b_on_journal_close := false


# Delegated properties for backward compatibility
var is_in_dialogue: bool:
	get:
		return dialogue_manager.is_in_dialogue if dialogue_manager else false

var current_world: Node3D:
	get:
		return scene_manager.current_world if scene_manager else null

var current_world_scene: String:
	get:
		return scene_manager.current_world_scene if scene_manager else ""


func _ready() -> void:
	Player = get_tree().get_first_node_in_group("Player")
	
	# Instantiate managers
	dialogue_manager = preload("res://Scripts/Managers/DialogueManager.gd").new()
	scene_manager = preload("res://Scripts/Managers/SceneManager.gd").new()
	game_event_handler = preload("res://Scripts/Managers/GameEventHandler.gd").new()
	signal_router = preload("res://Scripts/Managers/SignalRouter.gd").new()
	
	add_child(dialogue_manager)
	add_child(scene_manager)
	add_child(game_event_handler)
	add_child(signal_router)
	
	# Wait for Dialogic subsystems to be ready
	await _wait_for_dialogic_styles()
	
	# Skip game startup while Dialogic is running its editor timeline preview.
	if _is_dialogic_test_scene():
		return

	GlobalTracker.set_current_day(1)
	await change_viewport_world("res://Scenes/World_day1A.tscn")

	# Start dream sequence
	#start_dialogue("Dream_Trigger", true)




func _wait_for_dialogic_styles() -> void:
	while not Dialogic.has_subsystem("Styles"):
		await get_tree().process_frame


func start_dialogue(timeline: String, is_monologue: bool = false) -> void:
	await dialogue_manager.start_dialogue(timeline, is_monologue)


func change_viewport_world(new_scene_path: String) -> void:
	await scene_manager.change_viewport_world(new_scene_path)


func get_is_in_dialogue() -> bool:
	return dialogue_manager.is_in_dialogue


func _is_dialogic_test_scene() -> bool:
	var current_scene := get_tree().current_scene
	if not current_scene:
		return false
	var scene_path: String = current_scene.scene_file_path
	return scene_path.ends_with("addons/dialogic/Editor/TimelineEditor/test_timeline_scene.tscn")
	

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


	
