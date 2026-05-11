extends StaticBody3D
@onready var doorAnimation = $"../../CabinMainDoor"
var isFirstTimeOpen = true
var is_open = false
func interact():
	is_open = !is_open
	if is_open:
		doorAnimation.play("OpenDoor")
		$"../OpenSound".play()
	else:
		print("closing door")
		doorAnimation.play("CloseDoor")
		await Globals.wait(0.3)
		$"../CloseSound".play()
