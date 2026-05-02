extends StaticBody3D
var letterInventory := [
	{"reciever": "kei&dale", "delivered": false},
	{"reciever": "leus", "delivered": false},
	{"reciever": "lorie", "delivered": false},
	{"reciever": "thevalencianos", "delivered": false}
]

func interact(): 
	GlobalTracker.letterInventory = letterInventory
	Globals.start_dialogue("Timelines/Monologue_Day1_E", true)
