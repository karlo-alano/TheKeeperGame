extends Node3D



func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	Globals.start_dialogue("Penny_Day1_B")
