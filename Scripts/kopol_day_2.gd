extends Node3D


func _ready() -> void:
	Items.items["kopol"] = self
	
func appear():
	$KeiStanding.visible = true
	$DaleStanding.visible = true
	
func disappear():
	queue_free()
