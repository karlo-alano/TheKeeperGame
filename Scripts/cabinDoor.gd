extends StaticBody3D
@onready var doorAnimation = $"../../CabinMainDoor"
var isFirstTimeOpen = true
var is_open = false
func interact():
	is_open = !is_open
	if is_open:
		doorAnimation.play("OpenDoor")
		$"../OpenSound".play()
		if GlobalTracker.current_day == 2 and GlobalTracker.day2KopolFlag == true:
			Globals.start_dialogue("KeiDale_Day2_A")
	else:
		print("closing door")
		doorAnimation.play("CloseDoor")
		await Globals.wait(0.3)
		$"../CloseSound".play()
