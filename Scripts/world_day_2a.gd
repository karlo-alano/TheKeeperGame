extends Node3D

func _ready() -> void:

	GlobalTracker.set_current_day(2)
	Items.items["environment"].afternoonPosition()
	Items.items["door2c"].add_to_group("interactable")
	

	
	if GlobalTracker.run_once_per_day("world_day_2a_intro"):
		await get_tree().create_timer(3.0).timeout
		if is_inside_tree():
			#Globals.start_dialogue("Monologue_Day2_A", true)
			await Dialogic.timeline_ended
			_setup_day2()


func _setup_day2() -> void:
	GlobalTracker.set_current_day(2)
	var book = find_child("book", true, false)
	if book:
		var page = book.get_node_or_null("Cube_003/Page1/SubViewport/BookContents")
		if page and page.has_method("showDay"):
			page.showDay(2)
			print("[Day2A] showDay(2) called")
		else:
			print("[Day2A] page not found or missing showDay")
	else:
		print("[Day2A] book not found")

	Globals.emit_signal("show_action_prompt", true)
