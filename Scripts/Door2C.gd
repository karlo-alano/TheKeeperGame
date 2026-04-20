extends StaticBody3D

var is_open = false
func interact():
	is_open	= !is_open
	if is_open:
		$"../../Door2C".play("OpenDoor")
	else:
		$"../../Door2C".play("CloseDoor")
