extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Items.items["radio"] = self

func disappear():
	queue_free()
