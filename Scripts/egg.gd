extends Node3D
var hasEgg := false
@onready var sound := $"../Blip"

func obtain():
	GlobalTracker.eggCounter += 1
	hasEgg = true
	despawn()
	if GlobalTracker.eggCounter == 6:
		GlobalTracker.eggTaskCompleted = true
	
func despawn():
	owner.call_deferred("queue_free")
