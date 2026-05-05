extends StaticBody3D

func _ready() -> void:
	if GlobalTracker.current_day == 3:
		add_to_group("interactable")

func interact() -> void:
	if GlobalTracker.current_day != 3:
		return
	if GlobalTracker.run_once_per_day("mrs_valenciano_paluto_request"):
		Globals.start_dialogue("MrsValenciano_PalutoRequest", false)
