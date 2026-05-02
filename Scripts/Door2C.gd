extends StaticBody3D

var is_open := false
var slot := "Penny's Door"


func _ready():
	Items.items["door2c"] = self
	

func openDoor():
	$"../../Door2C".play("OpenDoor")
