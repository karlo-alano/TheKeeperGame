extends Control
@onready var label = $InteractLabel

func _ready():
	Globals.show_interact_prompt.connect(_on_show_prompt)

func _on_show_prompt(is_visible):
	label.visible = is_visible
