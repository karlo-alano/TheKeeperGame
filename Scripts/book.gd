extends StaticBody3D
@onready var animation := $BookAnimation

func openJournal():
	animation.play("BookOpening")
	
	
func closeJournal():
	animation.play("BookClosing")
	
	
