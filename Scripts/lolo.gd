extends Node3D
func _ready():
	print("Lolo ready!")
	Characters.characters["lolo"] = self

func interact():
	Globals.start_dialogue("Lolo_Day1_A", false)
	
func disappear():
	owner.queue_free()
