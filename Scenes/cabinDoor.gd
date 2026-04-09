extends AnimatableBody3D
@onready var doorAnimation = $"../../CabinMainDoor"
var is_open = false
func interact():
	print("interact called!")
	is_open = !is_open
	if is_open:
		doorAnimation.play("OpenDoor")
	else:
		print("closing door")
		doorAnimation.play("CloseDoor")
