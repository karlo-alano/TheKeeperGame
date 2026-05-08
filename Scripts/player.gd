extends CharacterBody3D

const SPEED = 3.5
const MOUSE_SENSITIVITY = 0.005

@onready var camera: Camera3D = $Camera3D
@onready var ray := $Camera3D/RayCast3D
@onready var hand := $Hand
@onready var blip := $Blip

@onready var journalAnimation := $JournalAnimation
@onready var journal := $book
@onready var letterAnimation := $GiveLetter
var held_object = null
var isJournalOpen := false



func _ready() -> void:
	Characters.characters["Player"] = self
	Globals.show_interact_prompt.emit(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	floor_max_angle = deg_to_rad(45)
	floor_snap_length = 1
	floor_stop_on_slope = true
	max_slides = 6
	journal.visible = isJournalOpen
	
	if GlobalTracker.current_day == 1 and GlobalTracker.run_once_per_day("player_auto_open_journal"):
		await get_tree().create_timer(3.0).timeout
		journalAnimation.play("OpenJournal")
		journal.openJournal()
		isJournalOpen = true
		journal.visible = isJournalOpen
	

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if held_object:
		if event.is_action_pressed("drop"):
			if held_object.has_method("onDrop"):
				held_object.onDrop()
			held_object.reparent(get_tree().current_scene)
			held_object.freeze = false
			held_object = null

	if event.is_action_pressed("journal"):
		if !isJournalOpen:
			journalAnimation.play("OpenJournal")
			journal.openJournal()
			var ui = get_tree().root.find_child("UI", true, false)
			if ui and ui.has_method("hide_journal_prompt"):
				ui.hide_journal_prompt()
			isJournalOpen = true
			journal.visible = isJournalOpen
		else:
			journalAnimation.play("CloseJournal")
			journal.closeJournal()
			isJournalOpen = false
			await get_tree().create_timer(1.0).timeout
			journal.visible = isJournalOpen

func _process(_delta: float):
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit == null or not is_instance_valid(hit):
			Globals.show_interact_prompt.emit(false)
			return
		if hit.is_in_group("interactable"):
			Globals.show_interact_prompt.emit(true)
			if Input.is_action_just_pressed("interact") and not Globals.is_in_dialogue:
					# Walk up parent chain to find a node with interact() or obtain()
					var interact_target = hit
					while interact_target != null:
						if interact_target.has_method("interact") or interact_target.has_method("obtain"):
							break
						interact_target = interact_target.get_parent()
					if interact_target != null:
						if interact_target.has_method("interact"):
							interact_target.interact()
						if interact_target.has_method("obtain"):
							print("[player] interact hit:", hit, "path:", hit.get_path(), "class:", hit.get_class())
							blip.play()
							print("[player] calling obtain() on:", interact_target.get_path())
							interact_target.obtain()
							print("[player] returned from obtain() call")
		if hit.is_in_group("pickable"):
			Globals.show_interact_prompt.emit(true)
			if Input.is_action_just_pressed("interact") and held_object == null and not Globals.is_in_dialogue:
				held_object = hit
				hit.freeze = true
				hit.reparent(hand)
				hit.position = Vector3.ZERO
				hit.rotation = Vector3.ZERO
				if hit.has_method("onPickup"):
					hit.onPickup()
		if hit.is_in_group("actionable") and held_object:
			print(hit)
			if !Globals.is_in_dialogue:
				# Safely read arbitrary properties using `get()` to avoid errors
				var hit_slot = hit.get("slot")
				var held_key = held_object.get("key") if held_object and held_object.has_method("get") else null
				if hit_slot != null and held_key != null and hit_slot == held_key:
					if Input.is_action_just_pressed("use"):
						if held_object.has_method("use"):
							held_object.use()
				
	else:
		Globals.show_interact_prompt.emit(false)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	


func _on_detection_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
