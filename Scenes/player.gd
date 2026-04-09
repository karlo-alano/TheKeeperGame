extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.005

@onready var camera: Camera3D = $Camera3D
@onready var ray = $Camera3D/RayCast3D


func _ready() -> void:
	Globals.show_interact_prompt.emit(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	floor_max_angle = deg_to_rad(45)
	floor_snap_length = 1
	floor_stop_on_slope = true
	max_slides = 6

func _unhandled_input(event: InputEvent) -> void:
	# Camera look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)

	# Release/capture mouse with Escape
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float):
	pass
	

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
	
	
	if ray.is_colliding():
			var hit = ray.get_collider()
			print("hitting: ", hit.name) 
			if hit.is_in_group("interactable"):
				Globals.show_interact_prompt.emit(true)
				if Input.is_action_just_pressed("interact"):
					if hit.has_method("interact"):
						hit.interact()

			else:
				Globals.show_interact_prompt.emit(false)
	else:
		Globals.show_interact_prompt.emit(false)
