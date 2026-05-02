extends StaticBody3D

var is_open := false
var slot := "Penny's Door"
func openDoor():
	$"../../Door2C".play("OpenDoor")
