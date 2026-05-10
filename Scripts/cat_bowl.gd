extends Node3D

const FEED_DURATION := 4.0
var slot := "Cat Bowl"
var current_feed_time := 0.0
var _fully_fed := false

@export var full_bowl_scene: PackedScene

func feed(delta: float) -> void:
	if _fully_fed:
		return
	current_feed_time += delta
	if current_feed_time >= FEED_DURATION:
		_fully_fed = true
		TasksManager.set_task_done(1, 3, true)
		TasksManager.add_put_it_back_task(1, "Cat Bowl")
		_swap_to_full_bowl()

func reset_progress() -> void:
	current_feed_time = 0.0

func _swap_to_full_bowl() -> void:
	if full_bowl_scene == null:
		full_bowl_scene = load("res://cat_bowl_with_food.tscn")
	var pos = global_position
	var rot = global_rotation
	var full_bowl = full_bowl_scene.instantiate()
	get_parent().add_child(full_bowl)
	full_bowl.global_position = pos
	full_bowl.global_rotation = rot
	queue_free()
