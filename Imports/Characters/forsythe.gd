extends Node3D

func _ready():
	Characters.characters["forsythe"] = self

func disappear():
	queue_free()
