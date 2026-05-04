extends Node3D



func _ready() -> void:
	Items.items["environment"].dayPosition()
	await get_tree().create_timer(2.0).timeout
	#Globals.start_dialogue("Timelines/Penny_Day1_B")
	
