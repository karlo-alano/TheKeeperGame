extends Node
signal show_interact_prompt(is_visible)

var Player: CharacterBody3D

func _ready():
	Player = get_tree().get_first_node_in_group("Player")
	
func start_dialogue(timeline: String, is_monologue: bool = false):
	if !is_monologue:
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
	Player.set_process_input(true)
	Player.set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
