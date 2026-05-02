extends Area3D
@onready var pan := $"../pan"


func interact():
	if GlobalTracker.eggTaskCompleted:
		Globals.start_dialogue("Monologue2B", true)
	else:
		pan.visible = true
		$"../cookingSounds".play()
		#await get_tree().create_timer(10.0).timeout
		$"../LunchBox".visible = true
		$CollisionShape3D.disabled = true
	
