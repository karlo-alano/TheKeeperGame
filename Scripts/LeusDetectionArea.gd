extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Globals.get_is_in_dialogue():
		return
	if GlobalTracker.current_day == 2 and GlobalTracker.day2LeusFlag:
		body.look_at(global_position)
		Globals.start_dialogue("Leus_Day2_A", false)
	else:
		return
