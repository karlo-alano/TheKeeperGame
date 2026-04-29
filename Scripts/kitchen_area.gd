extends Area3D
@onready var pan := $"../pan"

func interact():
	if GlobalTracker.eggCounter <= 0:
		Globals.start_dialogue("Monologue2B", true)
	elif GlobalTracker.eggCounter == 6:
		pan.visible = true
	
