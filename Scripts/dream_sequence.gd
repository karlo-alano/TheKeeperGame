extends Node3D

func _ready() -> void:
	while not Dialogic.has_subsystem("Styles"):
		await get_tree().process_frame
	await get_tree().process_frame
	Globals.start_dialogue("IntroPrayer", true)
