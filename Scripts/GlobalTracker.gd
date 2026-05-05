extends Node

# egg stuff
signal egg_collected
var _eggCounter: int = 0
var eggCounter: int:
	get:
		return _eggCounter
	set(value):
		_eggCounter = value
		egg_collected.emit()

var eggTaskCompleted := false
var dialogDone := false
var current_day: int = 1
var daily_event_flags := {}

# LunchBox
var isHoldingLunchbox := false

# Letters
var letterInventory := {
	"lorie": {"delivered": false},
	"leus": {"delivered": false},
	"lolo": {"delivered": false},
	"kei&dale": {"delivered": false},
	"thevalencianos": {"delivered": false}
}

# Journal
var isFirstTimeOpen := false

# TaskTracker
var cookingTaskCompleted := false
var allTasksCompleted := false


func set_current_day(day: int) -> void:
	if current_day == day:
		return
	current_day = day
	daily_event_flags.clear()
	dialogDone = false


func has_seen_today(event_id: String) -> bool:
	return daily_event_flags.get(_daily_event_key(event_id), false)


func mark_seen_today(event_id: String) -> void:
	daily_event_flags[_daily_event_key(event_id)] = true


func run_once_per_day(event_id: String) -> bool:
	if has_seen_today(event_id):
		return false
	mark_seen_today(event_id)
	return true


func _daily_event_key(event_id: String) -> String:
	return "%s:%s" % [current_day, event_id]
