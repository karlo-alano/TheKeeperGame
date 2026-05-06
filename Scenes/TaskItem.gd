extends HBoxContainer

@onready var task_name = $TaskName

func setup(p_name: String):
	task_name.text = p_name
