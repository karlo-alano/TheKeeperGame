extends Node3D
@onready var leus = $"."

func _ready():
	Characters.characters["leus"] = self

func disappear():
	queue_free()
	
func showSelf():
	leus.visible = true
