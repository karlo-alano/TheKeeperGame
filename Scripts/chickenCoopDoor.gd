extends StaticBody3D

var is_open = false
func interact():
	is_open	= !is_open
	if is_open:
		$"../../Roof/AnimationPlayer".play("openDoor")
	else:
		$"../../Roof/AnimationPlayer".play("closeDoor")
