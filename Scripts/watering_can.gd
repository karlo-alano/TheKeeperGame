extends RigidBody3D

@onready var collision := $CollisionShape3D
@onready var animation := $WateringCanAnimation

var key := "Garden Area"
var is_equipped := false

func onPickup():
	collision.disabled = true
	rotation = Vector3(-PI/2, -19.5, -PI/2)
	position = Vector3(0, -1, 0)
	is_equipped = true
	if GlobalTracker.current_day == 2:
		await Globals.wait(2.0)
		TasksManager.mark_task_done(2, 0)
		await Globals.wait(3.0)
		TasksManager.add_to_tasklist(2, "Put it back")

func onDrop():
	collision.disabled = false
	is_equipped = false
	var player = Characters.characters.get("Player")
	_stop_watering(player)
	var day := GlobalTracker.current_day
	var tasks: Array = TasksManager.task_list[day]["tasks"]
	if tasks.size() > 0 and tasks[0]["name"] == "Put it back":
		var zone = _get_return_zone()
		if zone and zone.check_drop(self):
			zone.deactivate()
			TasksManager.mark_task_done(day, 0)

func _get_return_zone() -> Node:
	return get_tree().root.find_child("WateringCanReturnZone", true, false)

func _process(delta):
	if not is_equipped:
		return

	var player = Characters.characters.get("Player")
	if player == null:
		return

	var ray = player.get("ray")
	var ui = get_tree().root.find_child("UI", true, false)
	var hold_label = ui.get_node_or_null("HoldLabel") if ui else null

	# Check if crosshair is on the garden patch (regardless of button state)
	var on_patch := false
	if ray != null and ray.is_colliding():
		var target = ray.get_collider()
		if target != null and is_instance_valid(target) and target.get("slot") == key:
			on_patch = true

	if Input.is_action_pressed("use") and on_patch:
		var target = ray.get_collider()

		# Hide "Hold E" prompt while actively holding
		if hold_label != null:
			hold_label.visible = false

		# Don't water if already fully watered
		if target.get("_fully_watered"):
			_stop_watering(player)
			return

		if target.has_method("water"):
			target.water(delta)

		# Play watering animation
		if not animation.is_playing():
			animation.play("Water")

		# Update the radial progress bar
		var progress_ui = ui.get_node_or_null("TextureProgressBar") if ui else null
		if progress_ui != null:
			var ratio = clampf(target.current_water_time / target.WATER_DURATION, 0.0, 1.0)
			if ratio < 1.0:
				progress_ui.visible = true
				progress_ui.value = ratio
			else:
				progress_ui.visible = false

	elif on_patch and not Input.is_action_pressed("use"):
		# Aiming at patch but not holding — show the "Hold E" prompt
		if hold_label != null and not ray.get_collider().get("_fully_watered"):
			hold_label.visible = true
		_stop_watering(player)

	else:
		# Not aiming at patch at all
		if hold_label != null:
			hold_label.visible = false
		_stop_watering(player)

func _stop_watering(player_node = null):
	if animation.is_playing() and animation.current_animation == "Water":
		animation.stop()
	var ui = get_tree().root.find_child("UI", true, false)
	var progress_ui = ui.get_node_or_null("TextureProgressBar") if ui else null
	if progress_ui != null:
		progress_ui.visible = false
		progress_ui.value = 0.0
