extends Node3D
func _ready():
	print("Lolo ready!")
	Characters.characters["lolo"] = self

func interact():
	if GlobalTracker.current_day == 1 and GlobalTracker.run_once_per_day("lolo_day1_a"):
		Globals.start_dialogue("Lolo_Day1_A", false)
	elif GlobalTracker.current_day == 3 and GlobalTracker.run_once_per_day("lolo_day3_a"):
		Globals.start_dialogue("Lolo_Day3_A", false)
	
func disappear():
	owner.queue_free()
