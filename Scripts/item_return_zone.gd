extends Node3D

@export var item_key: String = ""
@export var snap_radius: float = 0.8
@export var snap_target_path: NodePath
@export var ghost_size: Vector3 = Vector3(0.8, 0.8, 0.8)
@export var ghost_color: Color = Color(0.2, 0.95, 1.0, 0.55)

var _ghost: MeshInstance3D
var _active := false

func _ready() -> void:
	_ghost = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = ghost_size
	_ghost.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = ghost_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true
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

func snap_item(item: Node3D) -> void:
	var target := get_node_or_null(snap_target_path) as Node3D
	if target == null:
		target = self
	item.global_transform = target.global_transform
	if item is RigidBody3D:
		var body := item as RigidBody3D
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.freeze = true
