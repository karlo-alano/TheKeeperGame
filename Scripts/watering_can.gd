extends RigidBody3D
@onready var collision := $CollisionShape3D
@onready var animation := $WateringCanAnimation

var key := "Garden"

func onPickup():
	collision.disabled = true
	rotation = Vector3(-PI/2, -19.5, -PI/2)
	position = Vector3(0, -1, 0)
	if GlobalTracker.current_day == 2:
		await Globals.wait(2.0)
		TasksManager.mark_task_done(2,0)
		await Globals.wait(3.0)
		TasksManager.add_to_tasklist(2, "Put it back")
	
func use():
	animation.play("Water")

	var player = Characters.characters.get("Player")
	if player == null:
		return

	var ray = player.get("ray")
	if ray == null or not ray.is_colliding():
		return

	var target = ray.get_collider()
	print(target)
	if target == null or not is_instance_valid(target):
		return

	if target.get("slot") == key and target.has_method("water"):
		print("ladfj")
		target.water()
	
func onDrop():
	collision.disabled = false
	if TasksManager.task_list[2]["tasks"][0]["name"] == "Put it back":
		TasksManager.mark_task_done(2, 0)
