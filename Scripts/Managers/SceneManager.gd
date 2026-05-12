extends Node
## Manages scene loading, viewport management, and world state tracking.

var current_world_scene := ""
var current_world: Node3D = null

var player: CharacterBody3D:
	get:
		return Globals.Player


func change_viewport_world(new_scene_path: String) -> void:
	var viewport = get_tree().root.find_child("SubViewport", true, false)
	
	if viewport:
		# Create fade overlay (starts transparent, fades to black, then fades out after load)
		var fade_overlay = _create_fade_overlay()
		fade_overlay.modulate = Color(1, 1, 1, 0)  # Start transparent
		var ui_layer = get_tree().root
		ui_layer.add_child(fade_overlay)

		# Fade TO black first
		await _fade_in_overlay(fade_overlay, 1.0)

		# Load new world
		var old_world = viewport.get_node_or_null("World")
		if old_world:
			viewport.remove_child(old_world)
			old_world.queue_free()
		
		var new_world_res = load(new_scene_path)
		var new_world = new_world_res.instantiate()
		new_world.name = "World"
		
		# Ensure the loaded world doesn't inherit an unexpected scale (prevents Jolt physics warnings)
		if typeof(new_world) == TYPE_OBJECT and new_world.has_method("set_scale"):
			new_world.scale = Vector3.ONE
		else:
			# Try to sanitize transform basis if scale property isn't available
			new_world.transform = Transform3D(new_world.transform.basis.orthonormalized(), new_world.transform.origin)

		viewport.add_child(new_world)
		current_world = new_world

		# Record which scene was loaded so other scripts can adapt behavior
		current_world_scene = new_scene_path
		if new_scene_path.find("World_day1") != -1:
			GlobalTracker.set_current_day(1)
		elif new_scene_path.find("World_day2A") != -1:
			GlobalTracker.set_current_day(2)
		elif new_scene_path.find("World_day3A") != -1:
			GlobalTracker.set_current_day(3)
		
		await get_tree().process_frame
		Globals.Player = get_tree().get_first_node_in_group("Player")
		
		# Prepare audio for fade-in
		var audio_player = new_world.find_child("AudioStreamPlayer", true, false) as AudioStreamPlayer
		if audio_player:
			audio_player.volume_db = -80  # Start silent
			if not audio_player.playing:
				audio_player.play()
		
		# Fade out the overlay and fade in audio together
		await _fade_out_overlay(fade_overlay, audio_player)


func _create_fade_overlay() -> ColorRect:
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.z_index = 9999  # Ensure it's on top
	return overlay


func _fade_out_overlay(overlay: ColorRect, audio_player: AudioStreamPlayer = null, duration: float = 1.5) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate", Color(1, 1, 1, 0), duration)
	if audio_player:
		tween.tween_property(audio_player, "volume_db", 0.0, duration)
	await tween.finished
	overlay.queue_free()

func _fade_in_overlay(overlay: ColorRect, duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(overlay, "modulate", Color(1, 1, 1, 1), duration)
	await tween.finished
