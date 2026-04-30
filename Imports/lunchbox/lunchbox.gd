extends RigidBody3D
@onready var collision := $CollisionShape3D
var key := "Penny's Door"

func onPickup():
	position = Vector3(0, 0, 1)
	collision.disabled = true
	GlobalTracker.isHoldingLunchbox = true
func use():
	triggerCutscene()
	
func onDrop():
	collision.disabled = false
	GlobalTracker.isHoldingLunchbox = false


func triggerCutscene():
	Globals.start_dialogue("Penny_Day1_A", false)
	
	
		
