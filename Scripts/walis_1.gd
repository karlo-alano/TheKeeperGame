extends RigidBody3D

@onready var collision := $CollisionShape3D

var key := "Trash Area"
var is_equipped := false

func onPickup():
	collision.disabled = true
	position = Vector3(0, -1, 0)
	is_equipped = true

func onDrop():
	collision.disabled = false
	is_equipped = false
	var player = Characters.characters.get("Player")
	_stop_cleaning(player)

func _process(delta):
	if not is_equipped:
		return

	var player = Characters.characters.get("Player")
	if player == null:
		return

	var ray = player.get("ray")
	var hold_label = player.get_node_or_null("HUD/HoldLabel")

	# Check if crosshair is on a trash node (regardless of button state)
	var on_trash := false
	if ray != null and ray.is_colliding():
		var check = ray.get_collider()
		while check != null:
			if check.get("slot") == key:
				on_trash = true
				break
			check = check.get_parent()

	if Input.is_action_pressed("interact") and on_trash and not Globals.is_in_dialogue:
		var target = _get_trash_target(ray)

		# Hide "Hold E" prompt and suppress the base interact prompt while actively holding
		if hold_label != null:
			hold_label.visible = false
		Globals.show_interact_prompt.emit(false)

		# Don't clean if already fully cleaned or target is gone
		if target == null or target.get("_fully_cleaned"):
			_stop_cleaning(player)
			return

		if target.has_method("clean"):
			target.clean(delta)

		# Update the radial progress bar
		var progress_ui = player.get_node_or_null("HUD/TextureProgressBar")
		if progress_ui != null:
			var ratio = clampf(target.current_clean_time / target.CLEAN_DURATION, 0.0, 1.0)
			if ratio < 1.0:
				progress_ui.visible = true
				progress_ui.value = ratio
			else:
				progress_ui.visible = false

	elif on_trash and not Input.is_action_pressed("interact"):
		# Aiming at trash with broom — suppress "Press E" and show "Hold E" instead
		var target = _get_trash_target(ray)
		Globals.show_interact_prompt.emit(false)
		if hold_label != null and (target == null or not target.get("_fully_cleaned")):
			hold_label.visible = true
		_stop_cleaning(player)
		if target != null and target.has_method("reset_progress"):
			target.reset_progress()

	else:
		# Not aiming at trash at all
		if hold_label != null:
			hold_label.visible = false
		_stop_cleaning(player)

func _get_trash_target(ray) -> Node:
	if ray == null or not ray.is_colliding():
		return null
	var node = ray.get_collider()
	while node != null:
		if node.get("slot") == key:
			return node
		node = node.get_parent()
	return null

func _stop_cleaning(player_node = null):
	if player_node != null:
		var progress_ui = player_node.get_node_or_null("HUD/TextureProgressBar")
		if progress_ui != null:
			progress_ui.visible = false
			progress_ui.value = 0.0
