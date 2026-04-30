extends Control
@onready var interactLabel = $InteractLabel
@onready var actionLabel := $ActionLabel
@onready var tracker := $Tracker

func _ready():
	Globals.show_interact_prompt.connect(_show_interact)
	Globals.show_action_prompt.connect(_show_action)
	GlobalTracker.egg_collected.connect(updateTracker)
	updateTracker()

func _show_interact(is_visible):
	interactLabel.visible = is_visible

func _show_action(is_visible):
	actionLabel.visible = is_visible

func updateTracker():
	tracker.text = str(GlobalTracker.eggCounter) + "/6"
	
