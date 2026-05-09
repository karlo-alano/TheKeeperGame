extends Node3D

const CLEAN_DURATION := 6.0
const TOTAL_TRASH := 6

var slot := "Trash Area"
var current_clean_time := 0.0
var _fully_cleaned := false

static var cleaned_count := 0

func interact() -> void:
	Globals.start_dialogue("Monologue_TrashInspect", true)

func clean(delta: float) -> void:
	if _fully_cleaned:
		return
	current_clean_time += delta
	if current_clean_time >= CLEAN_DURATION:
		_fully_cleaned = true
		cleaned_count += 1
		if cleaned_count >= TOTAL_TRASH:
			TasksManager.set_task_done(1, 2, true)
			TasksManager.add_to_tasklist_delayed(1, "Put it back", 3.0)
		queue_free()

func reset_progress() -> void:
	current_clean_time = 0.0
