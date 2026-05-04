extends StaticBody3D

var slot := "Garden Area"

func _ready():
	Items.items["gardenPatch"] = self
	
