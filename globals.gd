extends Node
signal show_interact_prompt(is_visible)
signal show_action_prompt(is_visible)

var Player: CharacterBody3D
var is_in_dialogue := false

func _ready():
	Player = get_tree().get_first_node_in_group("Player")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	start_dialogue("Dream_Trigger", true)
	
	#change_viewport_world("res://Scenes/World_day1B.tscn")
	
func _on_dialogic_signal(argument):
	if argument == "startday":
		change_viewport_world("res://Scenes/World_day1A.tscn")
	if argument == "startdream":
		change_viewport_world("res://Scenes/dream_sequence.tscn")
	if argument == "cutscene1":
		Items.items["door2c"].openDoor()
	if argument == "changescene1":
		change_viewport_world("res://Scenes/World_day1B.tscn")
	if argument == "cutscene2":
		Characters.characters["forsythe"].disappear()
		DaySystem.dayInfo[1]["tasks"][0]["done"] = true
		

func change_viewport_world(new_scene_path: String):
	var viewport = get_tree().root.find_child("SubViewport", true, false)
	
	if viewport:
		var old_world = viewport.get_node_or_null("World")
		if old_world:
			old_world.queue_free()
		
		var new_world_res = load(new_scene_path)
		var new_world = new_world_res.instantiate()
		new_world.name = "World"
		
		viewport.add_child(new_world)
		
		await get_tree().process_frame
		Player = get_tree().get_first_node_in_group("Player")



func start_dialogue(timeline: String, is_monologue: bool = false):
	if !is_monologue:
		is_in_dialogue = true
		Player.set_process_input(false)
		Player.set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Dialogic.timeline_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
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
	Player.set_process_input(true)
	Player.set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
