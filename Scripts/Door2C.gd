extends StaticBody3D

var is_open := false
var slot := "Penny's Door"
var isOpenedOnce := false


func _ready():
	Items.items["door2c"] = self
	

func openDoor():
	$"../Door2C".play("OpenDoor")
	
func interact():
	if !is_open:
		if GlobalTracker.current_day == 2 and !isOpenedOnce:
			#Globals.start_dialogue("Lolo_Day2_A", false)
			Globals.start_dialogue("monologue", false)
		$"../Door2C".play("OpenDoor")
		is_open = !is_open
	else:
		$"../Door2C".play("CloseDoor")
		is_open = !is_open
