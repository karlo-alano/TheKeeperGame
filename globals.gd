extends Node
signal show_interact_prompt(is_visible)
signal show_action_prompt(is_visible)

var Player: CharacterBody3D
var is_in_dialogue := false

func _ready():
	Player = get_tree().get_first_node_in_group("Player")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
func _on_dialogic_signal(argument):
	if argument == "cutscene1":
		get_tree().get_first_node_in_group("door2c").openDoor()

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
	
