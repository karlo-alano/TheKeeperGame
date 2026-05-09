extends HBoxContainer

@onready var task_name = $TaskName

func setup(p_name: String, p_done: bool = false):
	if p_done:
		task_name.text = "[color=gray][s]%s[/s][/color]" % p_name
	else:
		task_name.text = p_name
