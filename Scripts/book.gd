extends StaticBody3D
@onready var animation := $BookAnimation
@onready var page1 := $Cube_003/Page1/SubViewport/BookContents

var counter := 0

func _ready() -> void:
	page1.DayLabel.text = "Day 1"

func openJournal():
	animation.play("BookOpening")
	page1.showDay(page1.currentDay)
	counter += 1
	if counter == 1:
		await get_tree().create_timer(1.0).timeout
		Globals.start_dialogue("Monologue2", true)
	
	
func closeJournal():
	animation.play("BookClosing")
	
	
