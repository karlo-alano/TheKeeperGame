extends StaticBody3D

const WATER_DURATION := 10.0
const DRY_TINT := Color.WHITE
const WET_TINT := Color(0.45734924, 0.30687293, 0.16883647, 1.0)
const WET_ROUGHNESS := 0.15

var slot := "Garden Area"
var current_water_time := 0.0
var _fully_watered := false
var _wet_material: StandardMaterial3D

static var watered_count := 0
static var total_patches := 0

signal watering_progress(progress_ratio)

func _ready():
	total_patches += 1
	_setup_wet_material()
	_apply_water_state()

func _exit_tree() -> void:
	total_patches -= 1
	if _fully_watered:
		watered_count -= 1

func water(delta: float) -> void:
	if _fully_watered:
		return
	current_water_time += delta
	emit_signal("watering_progress", current_water_time / WATER_DURATION)
	_apply_water_state()
	if current_water_time >= WATER_DURATION:
		_fully_watered = true
		current_water_time = WATER_DURATION
		emit_signal("watering_progress", 1.0)
		watered_count += 1
		if watered_count >= total_patches:
			TasksManager.set_task_done(1, 0, true)
			TasksManager.add_put_it_back_task(1, "Garden Area")

func _setup_wet_material() -> void:
	var patch_root := get_parent().get_parent()
	if patch_root == null:
		return

	for node in patch_root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue

		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var base_material := mesh_instance.mesh.surface_get_material(surface_index)
			if base_material is StandardMaterial3D and base_material.resource_name == "Dirt":
				if _wet_material == null:
					_wet_material = base_material.duplicate()
					_wet_material.resource_local_to_scene = true
					_wet_material.resource_name = "Dirt"
				mesh_instance.set_surface_override_material(surface_index, _wet_material)

func _apply_water_state() -> void:
	if _wet_material == null:
		return

	var wetness_ratio := current_water_time / WATER_DURATION
	_wet_material.albedo_color = DRY_TINT.lerp(WET_TINT, wetness_ratio)
	_wet_material.roughness = lerp(1.0, WET_ROUGHNESS, wetness_ratio)
