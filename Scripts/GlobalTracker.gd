extends Node

#egg stuff
var eggCounter := 0:
	set(value):
		eggCounter = value
		egg_collected.emit()

signal egg_collected

var eggTaskCompleted := false
var dialogDone := false

# LunchBox
var isHoldingLunchbox := false

# Letters
var letterInventory := {}

# Journal
var isFirstTimeOpen := false

# TaskTracker
var cookingTaskCompleted := false
var allTasksCompleted := false
