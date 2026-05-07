extends RigidBody3D
@onready var collision := $CollisionShape3D
@onready var animation := $WateringCanAnimation

var key := "Garden Area"

func onPickup():
	collision.disabled = true
	rotation = Vector3(-PI/2, -19.5, -PI/2)
	position = Vector3(0, -1, 0)
	
func use():
	animation.play("Water")
	
func onDrop():
	collision.disabled = false
