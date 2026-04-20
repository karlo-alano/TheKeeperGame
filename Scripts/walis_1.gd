extends RigidBody3D
@onready var sweep = $Walis1Sweep

func onPickup():
	var pickupText := "Time to sweep"
	
func use():
	sweep.play("Sweep")
