extends StaticBody3D
@onready var doorAnimation = $"../../CabinMainDoor"
var isFirstTimeOpen = true
var is_open = false
func interact():
	is_open = !is_open
	if is_open:
		doorAnimation.play("OpenDoor")
		if isFirstTimeOpen:
			isFirstTimeOpen = false
			await get_tree().create_timer(2.0).timeout
			Globals.start_dialogue("Monologue3", true)
	else:
		print("closing door")
		doorAnimation.play("CloseDoor")
