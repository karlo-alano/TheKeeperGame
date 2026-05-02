extends StaticBody3D

func interact():
	Globals.start_dialogue("KeiDale_Day1_A", false)
	var player = get_tree().get_first_node_in_group("Player")
	player.letterAnimation.play("give_letter")
	
	
