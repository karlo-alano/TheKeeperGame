extends RigidBody3D

@export var item_id: String = "food_box"

@onready var collision := $CollisionShape3D

var key := "Food Box Slot"
var is_equipped := false
var _home_global_transform: Transform3D

func _ready() -> void:
	_home_global_transform = global_transform
	call_deferred("_sync_objective_slot_home")

func _sync_objective_slot_home() -> void:
	for node in get_tree().get_nodes_in_group("objective_return_slots"):
		if node.has_method("sync_home_from_world_item"):
			node.sync_home_from_world_item(self)

func can_pickup() -> bool:
	return true

func onPickup():
	collision.disabled = true
	position = Vector3(0, -1, 0)
	is_equipped = true
	# Activate the ghost mesh to show delivery target
	for node in get_tree().get_nodes_in_group("objective_return_slots"):
		if str(node.get("expected_item_id")) == item_id:
			node.set_return_objective_active(true)

func onDrop():
	collision.disabled = false
	is_equipped = false
	var day := GlobalTracker.current_day
	var zone = _get_return_zone()
	if zone and zone.check_drop(self):
		zone.deactivate()
		global_transform = _home_global_transform
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		freeze = true
		TasksManager.complete_put_it_back_task(day, key)

func finalize_return_at_objective_slot() -> void:
	collision.disabled = false
	is_equipped = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	# Hide the ghost mesh directly
	for node in get_tree().get_nodes_in_group("objective_return_slots"):
		if str(node.get("expected_item_id")) == item_id:
			node.set_return_objective_active(false)
			if node.has_node("GhostMesh"):
				node.get_node("GhostMesh").visible = false
	TasksManager.mark_task_done_by_name(1, "Put the food box away")
	TasksManager.add_to_tasklist_delayed(1, "Talk to Lolo Aurelio", 2.0)

func _get_return_zone() -> Node:
	return get_tree().root.find_child("FoodBoxReturnZone", true, false)
