extends Control
@onready var label = $InteractLabel
@onready var tracker := $Tracker

func _ready():
	Globals.show_interact_prompt.connect(_on_show_prompt)
	GlobalTracker.egg_collected.connect(updateTracker)
	updateTracker()

func _on_show_prompt(is_visible):
	label.visible = is_visible

func updateTracker():
	tracker.text = str(GlobalTracker.eggCounter) + "/6"
	
