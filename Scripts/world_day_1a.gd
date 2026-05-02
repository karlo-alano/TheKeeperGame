extends Node3D

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	Globals.start_dialogue("Monologue1", true)

func _process(delta: float) -> void:
	pass
