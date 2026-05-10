extends Node3D

@export var expected_item_id: String = "" # Ita-type mo sa editor kung anong item ito
@export var ghost_model: Mesh # I-drag mo sa editor yung 3D model ng item
## Kapag wala kang ray hit sa ghost (walang collision), snap pa rin kung malapit ang player/camera sa FinalPosition.
@export var max_place_distance: float = 5.0

@onready var interaction_area = $InteractionArea
@onready var final_position = $FinalPosition
@onready var ghost_mesh = $GhostMesh

var current_item: Node3D = null
var _return_objective_active := false

func _ready():
	add_to_group("objective_return_slots")
	# SETUP NG GHOST
	ghost_mesh.visible = false
	if ghost_model:
		ghost_mesh.mesh = ghost_model
		ghost_mesh.material_override = preload("res://addons/ghost_material.tres")

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)


## Call from the world item (e.g. watering can) at start so FinalPosition matches its real rest pose.
func sync_home_from_world_item(item: Node3D) -> void:
	if item == null or not is_instance_valid(item):
		return
	if str(item.get("item_id")) != expected_item_id:
		return
	final_position.global_transform = item.global_transform
	_update_ghost_transform()


func set_return_objective_active(active: bool) -> void:
	_return_objective_active = active
	if active:
		_update_ghost_transform()
		ghost_mesh.visible = true
	else:
		if current_item == null:
			ghost_mesh.visible = false


func _update_ghost_transform() -> void:
	if ghost_mesh and final_position:
		ghost_mesh.global_transform = final_position.global_transform


# May item sa area
func _on_body_entered(body):
	if body.get("item_id") == expected_item_id:
		current_item = body
		_update_ghost_transform()
		ghost_mesh.visible = true


# Item umalis sa area
func _on_body_exited(body):
	if body == current_item:
		current_item = null
	if _return_objective_active:
		_update_ghost_transform()
		ghost_mesh.visible = true
		return
	ghost_mesh.visible = false


func _is_hit_from_this_slot(collider: Object) -> bool:
	if collider == null:
		return false
	var n: Node = collider as Node
	while n != null:
		if n == self:
			return true
		n = n.get_parent()
	return false


func _is_player_near_slot(player: Node3D) -> bool:
	if player == null:
		return false
	var cam := player.get_node_or_null("Camera3D") as Node3D
	var ref_pos: Vector3 = cam.global_position if cam else player.global_position
	return ref_pos.distance_to(final_position.global_position) <= max_place_distance


func can_accept_place(item: Node3D, ray_collider: Object, player: Node3D) -> bool:
	if expected_item_id == "" or str(item.get("item_id")) != expected_item_id:
		return false
	if not _return_objective_active:
		return false
	if _is_hit_from_this_slot(ray_collider):
		return true
	return _is_player_near_slot(player)


## Hinahawakan pa ng player — snap with tween (tween.finished → finalize), hindi physics drop.
func try_place_item(item: Node3D, player: Node3D) -> bool:
	var ray_collider: Object = null
	var plr_ray = player.get("ray") if player else null
	if plr_ray != null and plr_ray.is_colliding():
		ray_collider = plr_ray.get_collider()
	if not can_accept_place(item, ray_collider, player):
		return false

	player.held_object = null

	var scene: Node = get_tree().current_scene
	item.reparent(scene)
	item.global_transform = item.global_transform
	if item is RigidBody3D:
		var rb := item as RigidBody3D
		rb.linear_velocity = Vector3.ZERO
		rb.angular_velocity = Vector3.ZERO
		rb.freeze = true

	ghost_mesh.visible = false

	var tw := create_tween()
	tw.set_parallel(true)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(item, "global_position", final_position.global_position, 0.25)
	tw.tween_property(item, "global_rotation", final_position.global_rotation, 0.25)
	tw.finished.connect(_on_snap_tween_done.bind(item), CONNECT_ONE_SHOT)
	return true


func _on_snap_tween_done(item: Node3D) -> void:
	if not is_instance_valid(item):
		return
	if item.has_method("finalize_return_at_objective_slot"):
		item.finalize_return_at_objective_slot()
	elif item.has_method("onDrop"):
		item.onDrop()
	set_return_objective_active(false)


func try_drop_item(item_being_dropped: Node3D) -> bool:
	var p: Node = Characters.characters.get("Player", null)
	if p == null:
		return false
	return try_place_item(item_being_dropped, p)
