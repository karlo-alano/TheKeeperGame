extends Control
@onready var interactLabel = $InteractLabel
@onready var actionLabel := $ActionLabel
@onready var journalHintLabel := $JournalHintLabel
@onready var tracker := $Tracker

var _journal_prompt_token := 0

func _ready():
	Globals.show_interact_prompt.connect(_show_interact)
	Globals.show_action_prompt.connect(_show_action)
	GlobalTracker.egg_collected.connect(updateTracker)
	updateTracker()

func _show_interact(is_visible):
	interactLabel.visible = is_visible

func _show_action(is_visible):
	actionLabel.visible = is_visible


func show_journal_prompt() -> void:
	_journal_prompt_token += 1
	var token := _journal_prompt_token
	journalHintLabel.text = "Press G to open the journal"
	journalHintLabel.visible = true
	await get_tree().create_timer(20.0).timeout
	if token == _journal_prompt_token and journalHintLabel.visible:
		journalHintLabel.visible = false


func hide_journal_prompt() -> void:
	_journal_prompt_token += 1
	journalHintLabel.visible = false

func updateTracker():
	tracker.text = str(GlobalTracker.eggCounter) + "/6"
	
