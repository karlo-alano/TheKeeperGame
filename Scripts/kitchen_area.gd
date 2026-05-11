extends Area3D
@onready var pan := get_node_or_null("../pan")


func interact():
	if GlobalTracker.current_day == 1:
		if not GlobalTracker.eggTaskCompleted:
			Globals.start_dialogue("Monologue2B", true)
			return

		# show pan if it exists
		if pan:
			pan.visible = true

		var cook_sounds = get_node_or_null("../cookingSounds")
		if cook_sounds and cook_sounds.has_method("play"):
			cook_sounds.play()

		await get_tree().create_timer(10.0).timeout

		var lunchbox = get_node_or_null("../LunchBox")
		if lunchbox:
			lunchbox.visible = true

		var col = get_node_or_null("CollisionShape3D")
		if col:
			col.disabled = true

		var lolo = null
		if Characters.characters.has("lolo"):
			lolo = Characters.characters["lolo"]
		if lolo and is_instance_valid(lolo):
			if lolo.has_method("disappear"):
				lolo.disappear()

		if Items.items.has("radio") and Items.items["radio"] and is_instance_valid(Items.items["radio"]):
			if Items.items["radio"].has_method("disappear"):
				Items.items["radio"].disappear()
	elif GlobalTracker.current_day == 2:
		if GlobalTracker.eggTaskCompleted:
			await Globals.wait(2.0)
			$"../../Door_001/Knock".play()
		
