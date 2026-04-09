extends Control
func _ready():
	Globals.show_interact_prompt.connect(_on_show_prompt)

func _on_show_prompt(is_visible):
	$InteractLabel.visible = is_visible
