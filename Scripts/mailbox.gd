extends StaticBody3D
var letterInventory = {
	"lorie": {"delivered": false},
	"leus": {"delivered": false},
	"lolo": {"delivered": false},
	"kei&dale": {"delivered": false},
	"thevalencianos": {"delivered": false}
}

func interact(): 
	GlobalTracker.letterInventory = letterInventory
	Globals.start_dialogue("Timelines/Monologue_Day1_E", true)
