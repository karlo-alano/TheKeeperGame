extends Control

@onready var interactLabel = $InteractLabel
@onready var journalHintLabel := $JournalHintLabel
@onready var tracker := $Tracker
@onready var task_bar = $TaskBar  # ← add this

var _journal_prompt_token := 0

func _ready():
	Globals.show_interact_prompt.connect(_show_interact)
	GlobalTracker.egg_collected.connect(updateTracker)
	DaySystem.task_done_changed.connect(_on_task_done_changed)
	updateTracker()

func _on_task_done_changed(_day: int, _index: int, _done: bool) -> void:
	task_bar.refresh()

func _show_interact(is_visible):
	interactLabel.visible = is_visible

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

func refresh_taskbar():            # ← add this
	task_bar.refresh()
