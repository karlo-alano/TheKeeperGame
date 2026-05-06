extends StaticBody3D
@onready var animation := $BookAnimation
@onready var page1 := $Cube_003/Page1/SubViewport/BookContents

signal journal_closed

var counter := 0

func _ready() -> void:
	page1.showDay(GlobalTracker.current_day)

	# allow Dialogic/global hooks to find this book easily
	name = "book"

func openJournal():
	animation.play("BookOpening")
	page1.showDay(GlobalTracker.current_day)
	if GlobalTracker.current_day == 1 and GlobalTracker.run_once_per_day("journal_open_intro"):
		await get_tree().create_timer(1.0).timeout
		
	
	
func closeJournal():
	animation.play("BookClosing")
	journal_closed.emit()

func toggleJournal():
	# simple toggle: if Page1 is visible in its viewport, hide/close
	if page1.visible:
		closeJournal()
	else:
		openJournal()

# Journal API delegations
func add_entry(id:String, title:String, body:String, day:int = -1) -> void:
	if page1:
		page1.add_entry(id, title, body, day)

func update_entry(id:String, data:Dictionary) -> void:
	if page1:
		page1.update_entry(id, data)

func get_entry(id:String) -> Dictionary:
	if page1:
		return page1.get_entry(id)
	return {}
	
	
