extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Items.items["dialogbox"] = self
	var cursor = preload("res://Imports/cursor.png")
	await get_tree().create_timer(2.0).timeout
	Input.set_custom_mouse_cursor(cursor)

func _process(delta: float) -> void:
	pass
	
func showDialog():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$".".visible = true
	
	
func make_mouse_fight_control():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var tween = create_tween()
	tween.tween_method(func(pos): Input.warp_mouse(pos), 
					   Vector2(100, 100),
					   Vector2(500, 300),  
					   0.5)
