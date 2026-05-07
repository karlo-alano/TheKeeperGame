extends StaticBody3D

var is_open := false
var slot := "Penny's Door"


func _ready():
	Items.items["door2c"] = self
	

func openDoor():
	$"../Door2C".play("OpenDoor")
	
func interact():
	if !is_open:
		if GlobalTracker.current_day == 2:
			$"../Door2C".play("OpenDoor")
			is_open = !is_open
			Globals.start_dialogue("Lolo_Day2_A", false)
	else:
		$"../Door2C".play("CloseDoor")
		is_open = !is_open
