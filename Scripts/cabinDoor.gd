extends StaticBody3D
@onready var doorAnimation = $"../../CabinMainDoor"
var isFirstTimeOpen = true
var is_open = false
func interact():
	is_open = !is_open
	if is_open:
		doorAnimation.play("OpenDoor")
		if isFirstTimeOpen and GlobalTracker.current_day != 3:
			isFirstTimeOpen = false
			await get_tree().create_timer(2.0).timeout
			# choose a day-appropriate monologue based on loaded world
			var timeline := "Monologue3"
			Globals.start_dialogue(timeline, true)
	else:
		print("closing door")
		doorAnimation.play("CloseDoor")
