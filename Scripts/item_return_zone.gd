extends Node3D

@export var item_key: String = ""
@export var snap_radius: float = 0.8

var _ghost: MeshInstance3D
var _active := false

func _ready() -> void:
	_ghost = MeshInstance3D.new()
	_ghost.mesh = BoxMesh.new()
	_ghost.mesh.size = Vector3(0.3, 0.3, 0.3)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 1.0, 0.35)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost.material_override = mat
	_ghost.visible = false
	add_child(_ghost)

func activate() -> void:
	_active = true
	_ghost.visible = true

func deactivate() -> void:
	_active = false
	_ghost.visible = false

func check_drop(item: Node3D) -> bool:
	if not _active:
		return false
	var dist = global_position.distance_to(item.global_position)
	return dist <= snap_radius
